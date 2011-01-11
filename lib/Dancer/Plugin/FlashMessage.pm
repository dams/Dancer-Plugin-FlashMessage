package Dancer::Plugin::FlashMessage;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;

our $AUTHORITY = 'DAMS';
our $VERSION = '0.1';

my $conf = plugin_setting;

my $auto_display        = $conf->{auto_display}        || 1;
my $auto_remove         = $conf->{auto_remove}         || 1;
my $token_name          = $conf->{token_name}          || '_flash';
my $session_message_key = $conf->{session_message_key} || '_flash_message';
my $session_display_key = $conf->{session_display_key} || '_flash_display';

my $remove = sub () { session $session_display_key, 0;
                      session $session_message_key, undef };

register set_flash => sub ($) {
    session $session_message_key, shift;
    $auto_display
      and session $session_display_key, 1;
};

register display_flash => sub () { session $session_display_key, 1 };

register remove_flash => sub { $remove->() };

before_template sub {
    session $session_display_key
      or return;
    shift->{$token_name} = session $session_message_key;
    $auto_remove
      and $remove->();
};

register_plugin;

1;

__END__

=pod

=head1 NAME

Dancer::Plugin::FlashMessage - A plugin to display "flash messages" : short temporary messages

=head1 SYNOPSYS

In your index.tt view or in your layout :

  <% IF _flash_message %>
    <div class=flash> <% _flash_message %> </div>
  <% END %>

In your css :
  .flash { background: #CEE5F5; padding: 0.5em;
           border: 1px solid #AACBE2; }

In your Dancer App :

  package MyWebService;

  use Dancer;
  use Dancer::Plugin::FlashMessage;

  get '/hello' => sub {
      set_flash()
      template 'index';
  };

=head1 DESCRIPTION

This plugin helps you display temporary messages, so called "flash messages".
It proposes a C<set_flash()> method to define the content of the message. The
plugin then takes care of attaching the content to the session, propagate it to
the templating system, and then remove it from the session.

However, it's up to you to have a place in your views or layout where the
message will be displayed. But that's not too hard (see L<SYNOPSYS>).

By default, the plugin works using a descent default configuration. However,
you can change the behaviour of the plugin, so that flash messages are not
automatically displayed or removed. See L<CONFIGURATION>

=head1 METHODS

=head2 set_flash

This method takes a message (string) as argument, and stores it in the session
as being the flash message content. Depending of the configuration, the flash
message will be displayed automatically, or you'll have to call
C<display_flash()> to display it.

=head2 display_flash

This method is to be called only if the C<auto_display> configuration key is
set to false. It will make sure the flash message is displayed in the next view
rendering. Depending of the configuration, the message may be removed
automatically, or you'll have to call C<remove_flash>

=head2 remove_flash

This method is to be called only if the C<auto_remove> configuration key is
false. When called, it will delete the flash message content from the session,
and set its display flag to false, so the flash message will stop being displayed.

=head1 CONFIGURATION

=head2 no configuration

With no configuration whatsoever, the plugin will work fine, thus contributing
to the I<keep it simple> motto of Dancer.

=head2 configuration default

These are the default values. See below for a description of the keys

  plugins:
    FlashMessage:
      auto_display: 1
      auto_remove: 1
      token_name: _flash
      session_message_key: _flash_message
      session_display_key: _flash_display

=head2 configuration description

=over

=item auto_display

If set to true, once set, the flash message will be displayed next time (and possibly
following times, see C<auto_remove>) you render a view. Default : 1

=item auto_remove

If set to true, once displayed, the flash message will be automatically hidden
and deleted. Default : 1

=item token_name

The name of the template token that will contain the flash message content. Default : _flash

=item session_message_key

You probably don't need that, but this setting allows you to change the name of
the session key used to store the flash message content. It may be useful in
the unlikely case wher you have key name conflicts in your session. Default :
_flash_message

=item session_display_key

You probably don't need that, but this setting allows you to change the name of
the session key used to store the fact that the flash message needs to be
displayed. It may be useful in the unlikely case wher you have key name
conflicts in your session. Default : _flash_display

=back

=head1 LICENCE

This module is released under the same terms as Perl itself.

=head1 AUTHORS

This module has been written by Damien Krotkine <dams@cpan.org>.

=head1 SEE ALSO

L<Dancer>

=cut
