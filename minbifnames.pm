package minbifnames;
use base 'ZNC::Module';
use Text::Unidecode;
use Encode qw(decode);

use strict;

sub description {
    "Use Facebook and Google-Chat full names in Minbif."
}

sub OnModCommand {
  my ($self, $cmd) = @_;

  if ($cmd =~ /^help/) {
    return $self->PutModule("See https://github.com/oz/minbifnames");
  }

  if ($cmd =~ /^set ([a-z_]+) ([^\s]+)/) {
    return $self->set_nv_value($1, $2);
  }

  if ($cmd =~ /^get ([a-z_]+)/) {
    return $self->show_nv_value($1);
  }

  $self->PutModule("Invalid command.");
}

sub OnRaw {
  my ($self, $sLine) = @_;
  my ($myhost, $code, $me, $nick, $user, $host, $rest) = split(" ", $sLine);

  if ($code eq '311' && exists($self->{renaming}{$nick})) {
    $self->change_nick($nick, $sLine);
    return $ZNC::HALT;
  }

  return $ZNC::CONTINUE;
}

sub OnJoin {
  my ($self, $nickObj, $chanObj) = @_;
  my $nick    = $nickObj->GetNick;
  my $chan    = $chanObj->GetName;
  my $network = $self->social_network_name($nickObj->GetHost);

  # Ignore joins from non-minbif chans, or from accounts other than Google or
  # Facebook.
  return $ZNC::CONTINUE unless $chan eq $self->minbif_channel();
  return $ZNC::CONTINUE if ($network eq 'unknown');

  $self->{renaming}{$nick} = [$chan, $network];
  $self->PutIRC("whois $nick");

  return $ZNC::CONTINUE;
}

# Change a contact's nick with the received /whois data.
sub change_nick {
  my ($self, $nick, $whois) = @_;

  my ($chan, $network) = @{$self->{renaming}{$nick}};
  delete($self->{renaming}{$nick});

  # Extract the contact's name from whois data.
  my @parts     = split(/ :/, $whois);
  my @nickparts = split(/ \[/, $parts[-1]);
  my $ircname   = trim($nickparts[0]);

  # Make an acceptable nick.
  $ircname = $self->network_affix($network, $self->munge_nick($ircname));
  return if $ircname eq $nick;

  # Tell minbif to update the contact's nick for us.
  $self->PutIRC("SVSNICK $nick $ircname");
}

sub minbif_channel {
  my ($self) = @_;

  return $self->get_nv_or_default("minbif_channel", "&minbif");
}

sub facebook_host {
  my ($self) = @_;

  return $self->get_nv_or_default("facebook_host", "chat.facebook.com");
}

sub google_host {
  my ($self) = @_;

  return $self->get_nv_or_default("google_host", "public.talk.google.com");
}

# Detect the social network from the contact's host.
sub social_network_name {
  my ($self, $host) = @_;

  if ($host =~ $self->google_host()) {
    return 'google';
  } elsif ($host =~ $self->facebook_host()) {
    return 'facebook';
  }

  return 'unknown';
}

# Get a module's NV value, or return a the supplied default.
sub get_nv_or_default {
  my ($self, $name, $default) = @_;
  my $nv = $self->NV;

  if ($self->ExistsNV($name)) {
    return $self->GetNV($name);
  }

  return $default;
}

# Save key/value to module config.
sub set_nv_value {
  my ($self, $name, $value) = @_;

  $self->SetNV($name, $value);
  $self->PutModule("Ok, $name set to $value");
}

# Show module config (by key).
sub show_nv_value {
  my ($self, $name) = @_;

  my $value = $self->GetNV($name);
  $self->PutModule("$name is set to: $value");

  return $value;
}

# Make an acceptable IRC nick from a name. The notion of "acceptable" greatly
# varies between individuals, so here's what is done here:
#
#   - Trim eventual surrounding space characters,
#   - use a single underscore (_) instead of consecutive spaces,
#   - if the "transliterate" option is set to "true" (default), we also:
#     - transliterate non-roman UTF-8 characters to US-ASCII,
#     - and strip every non-alphanumerical character (accepting _ and -).
#
# Examples with transliterate set to "true":
#   "John Smith"            -> "John_Smith"
#   "Jean-Kévin de la Tour" -> "Jean-Kevin_de_la_Tour"
#   "Mike R.   "            -> "Mike_R"
sub munge_nick {
  my ($self, $nick) = @_;

  $nick = trim(decode('utf8', $nick));
  $nick =~ s/\s+/_/g;

  if ($self->get_nv_or_default("transliterate", "true") eq "true") {
    $nick = unidecode($nick);
    $nick =~ s/[^A-Za-z0-9_-]//g;
  }

  return $nick;
}

# If a network affix is set, append or prepend it to a given nick.
sub network_affix {
  my ($self, $network, $nick) = @_;

  my $prefix = $self->get_nv_or_default($network . "_prefix", "");
  my $suffix = $self->get_nv_or_default($network . "_suffix", "");

  return $prefix . $nick . $suffix;
}

sub trim {
  my ($str) = @_;

  $str =~ s/^\s+//;
  $str =~ s/\s+$//;

  return $str;
}

1;
