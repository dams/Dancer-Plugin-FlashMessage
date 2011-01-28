package Dancer::Plugin::FlashMessage;

# ABSTRACT: Dancer plugin to display temporary messages, so called "flash messages".

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;

our $AUTHORITY = 'DAMS';
our $VERSION = '0.2';

my $conf = plugin_setting;

my $token_name       = $conf->{token_name}       || 'flash';
my $session_hash_key = $conf->{session_hash_key} || '_flash';
my $persistence      = $conf->{persistence}      || 0;

register flash => sub ($;$) {
    my ($key, $value) = @_;
    my $flash = session $session_hash_key || {};
    @_ == 2 and $flash->{$key} = $value;
    @_ == 1 and $value = $persistence ? $flash->{$key} : delete $flash->{$key};
    session $session_hash_key, $flash;
    return $value;
};

before_template sub {
   shift->{$token_name} = {  map { my $key = $_; my $value;
                                   ( $key, sub { defined $value and return $value;
                                                 my $flash = session $session_hash_key || {};
                                                 $value = $persistence ? $flash->{$key} : delete $flash->{$key};
                                                 session $session_hash_key, $flash;
                                                 return $value;
                                               } );
                                 } ( keys %{session $session_hash_key || {} })
                          };
};

register_plugin;

1;

__END__

=pod

=head1 NAME

Dancer::Plugin::FlashMessage - A plugin to display "flash messages" : short temporary messages

=head1 SYNOPSYS

Example with Template Toolkit: in your index.tt view or in your layout :

  <% IF flash.error %>
    <div class=error> <% flash.error %> </div>
  <% END %>

In your css :

  .error { background: #CEE5F5; padding: 0.5em;
           border: 1px solid #AACBE2; }

In your Dancer App :

  package MyWebService;

  use Dancer;
  use Dancer::Plugin::FlashMessage;

  get '/hello' => sub {
      flash error => 'Error message';
      template 'index';
  };

=head1 DESCRIPTION

This plugin helps you display temporary messages, so called "flash messages".
It provides a C<flash()> method to define the message. The plugin then takes
care of attaching the content to the session, propagating it to the templating
system, and then removing it from the session.

However, it's up to you to have a place in your views or layout where the
message will be displayed. But that's not too hard (see L<SYNOPSYS>).

Basically, the plugin gives you access to the 'flash' hash in your views. It
can be used to display flash messages.

By default, the plugin works using a descent configuration. However, you can
change the behaviour of the plugin. See L<CONFIGURATION>

=head1 METHODS

=head2 flash

  # sets the flash message for the warning key
  flash warning => 'some warning message';

  # retrieves and removes (unless persistence is true) the flash message for
  # the warning key
  my $warning_message = flash 'warning';

This method can take 1 or 2 parameters. When called with two parameters, it
sets the flash message for the given key.

When called with one parameter, it returns the value of the flash message of
the given key. It usually also deletes this entry, but if you have set the
'persistence' configuration key to true, the entry won't be deleted. See below

In both cases, C<flash> always returns the value;

=head1 CONFIGURATION

With no configuration whatsoever, the plugin will work fine, thus contributing
to the I<keep it simple> motto of Dancer.

=head2 configuration default values

These are the default values. See below for a description of the keys

  plugins:
    FlashMessage:
      persistence: 0
      token_name: flash
      session_hash_key: _flash

=head2 configuration description

=over

=item persistence

If set to a true value, flash messages will be persistent, i.e. survive more
than one request. If set to a false value, flash messages will be suppressed
once templating has been done. B<Default> : C<0>

=item token_name

The name of the template token that will contain the hash of flash messages.
B<Default> : C<flash>

=item session_hash_key

You probably don't need that, but this setting allows you to change the name of
the session key used to store the hash of flash messages. It may be useful in
the unlikely case where you have key name conflicts in your session. B<Default> :
C<_flash>

=back

=head1 COPYRIGHT

This software is copyright (c) 2011 by Damien "dams" Krotkine <dams@cpan.org>.

=head1 LICENCE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 AUTHORS

This module has been written by Damien "dams" Krotkine <dams@cpan.org>.

=head1 SEE ALSO

L<Dancer>

=cut
