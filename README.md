# Minbif Names

This is a Perl module for the [ZNC][znc] IRC bouncer, when used with
[Minbif][minbif].

When connecting to Facebook Chat, or Google Talk through XMPP, you unavoidably
noticed that your precious contacts names are mangled to a bunch of
alphanumerical garbage.

There are quite a few irssi, or weechat, scripts to automatically rename them
to something less ugly.  This module does the same thing directly from ZNC.

# Requirements

  * ZNC (tested at version >= 1.0), compiled with Perl support.
  * `Text::Unidecode` Perl module: just install the `libtext-unidecode-perl`
    package on Debian-like distributions.

# Installation

  1. Copy the `minbifnames.pm` file to your ZNC user's module directory

      ```
        curl https://raw.github.com/oz/minbifnames/master/minbifnames.pm > $HOME/.znc/modules
      ```

  2. From your IRC session, while connected to ZNC, send the following commands
     to the `*status` user of the Minbif network.

      ```
      loadmod modperl
      loadmod minbifnames
      ```

  3. Reconnect your Facebook or Google accounts from Minbif.

# Known limitations

If you share a contact between Google and Facebook, that is using the same name
on both networks, you'll have a nick collision.  So the renaming will only
happen on the first connected contact.

# Bugs

Probably. Patches welcome! :)

[znc]: http://znc.in/
[minbif]: http://minbif.im
