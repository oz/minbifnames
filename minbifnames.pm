package minbifnames;
use base 'ZNC::Module';
use Text::Unidecode;
use Encode qw(decode);

use strict;

sub description {
    "Name Facebook and Google Chat users correcty in minbif roster."
}

sub minbif_channel { "&minbif" }
sub facebook_host  { "chat.facebook.com" }
sub google_host    { "public.talk.google.com" }

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
  my $network = social_network_name($nickObj->GetHost);

  # Ignore joins from non-minbif chans, or from accounts other than Google or
  # Facebook.
  return $ZNC::CONTINUE unless $chan eq minbif_channel();
  return $ZNC::CONTINUE if ($network eq 'unknown');

  $self->{renaming}{$nick} = $chan;
  $self->PutIRC("whois $nick");

  return $ZNC::CONTINUE;
}

sub change_nick {
  my ($self, $nick, $whois) = @_;

  my $chan = $self->{renaming}{$nick};
  delete($self->{renaming}{$nick});

  # Extract the contact's name from whois data.
  my @parts     = split(/ :/, $whois);
  my @nickparts = split(/ \[/, $parts[-1]);
  my $ircname   = trim($nickparts[0]);

  # Make an acceptable nick.
  $ircname = munge_nick($ircname);
  return if $ircname eq $nick;

  # Tell minbif to update the contact's nick for us.
  $self->PutIRC("SVSNICK $nick $ircname");
}

# Detect the social network from the contact's host.
sub social_network_name {
  my ($host) = @_;

  if ($host =~ google_host()) {
    return 'google';
  } elsif ($host =~ facebook_host()) {
    return 'facebook';
  }

  return 'unknown';
}

# Make an acceptable IRC nick from a name, example:
#
#   "Kévin de la Tour" becomes "Kevin_de_la_Tour"
sub munge_nick {
  my ($nick) = @_;

  $nick = decode('utf8', $nick);
  $nick =~ s/[- ]/_/g;
  $nick = unidecode($nick);
  $nick =~ s/[^A-Za-z0-9_-]//g;

  return $nick;
}

# Trimming strings...
sub trim {
  my ($str) = @_;

  $str =~ s/^\s+//;
  $str =~ s/\s+$//;

  return $str;
}

1;
