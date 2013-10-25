# Minbif Names

This is a Perl module for the [ZNC][znc] IRC bouncer, when used with
[Minbif][minbif].

When connecting to Facebook Chat, or Google Talk through XMPP, you unavoidably
noticed that your precious contacts names are mangled to a bunch of
alphanumerical garbage.

There are quite a few irssi, or weechat, scripts to automatically rename them
to something less ugly.  This module does the same thing directly from ZNC.

If you're using [BitlBee][bitlbee] rather than Minbif, take a look at draggy's
[znc-perl-bitlbee-facebook-rename][bitlbee_module], from which part of this code
is derived. :)

# Requirements

  * ZNC (tested at version >= 1.0), compiled with Perl support.
  * `Text::Unidecode` Perl module (just install the `libtext-unidecode-perl`
    package on Debian-like distributions).

# Installation

  1. Copy the `minbifnames.pm` file to your ZNC user's module directory.

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

# Configuration

A few options are available to tweak the module's behavior, to change the
defaults, send messages to the `*minbifnames` user:

  * to show a configuration key, use `get some_key`,
  * and to set a configuration key, use `set some_key some_value`.

Useful configuration keys:

  * `transliterate`: whether non-roman characters are transliterated to
    US-ASCII, default: `true`.
  * `google_prefix`: prefix for Google contacts, default: "".
  * `google_suffix`: suffix for Google contacts, default: "".
  * `google_host`:   host used to detect Google contacts, default:
    `public.talk.google.com`.
  * `facebook_prefix`: prefix for Facebook contacts, default: "".
  * `facebook_suffix`: suffix for Facebook contacts, default: "".
  * `facebook_host`: host used to detect Facebook contacts, default:
    `chat.facebook.com`.
  * `minbif_channel`: Minbif's control channel name, default: `&minbif`.

# Known limitations

If you share a contact between Google and Facebook, that is using the same name
on both networks, you'll have a nick collision.  So the renaming will only
happen on the first connected contact.

# Bugs

Probably. Patches welcome! :)

[znc]: http://znc.in/
[minbif]: http://minbif.im/
[bitlbee]: http://www.bitlbee.org/
[bitlbee_module]: https://github.com/draggy/znc-perl-bitlbee-facebook-rename
