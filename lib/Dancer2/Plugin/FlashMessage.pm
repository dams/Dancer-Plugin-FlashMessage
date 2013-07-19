use strict;
use warnings;

package Dancer2::Plugin::FlashMessage;
# ABSTRACT: Dancer plugin to display temporary messages, so called "flash messages".

use Carp;
use Dancer2::Plugin;

our $AUTHORITY = 'DAMS';

my ($conf, $session_hash_key, $token_name);

register flash => sub {
    my ($dsl, $key, $value) = @_;

    $dsl->engine('session')
      or croak __PACKAGE__ . " error2 : there is no session engine configured in the configuration. You need a session engine to be able to use this plugin";

    my $flash = $dsl->session($session_hash_key) || {};
    @_ == 3 and $flash->{$key} = $value;
    @_ == 2 and $value = delete $flash->{$key};
    $dsl->session($session_hash_key, $flash);

    return $value;
};

on_plugin_import {
    my $dsl = shift;

    $conf = plugin_setting();
    $session_hash_key = $conf->{session_hash_key} || '_flash';
    $token_name       = $conf->{token_name} || 'flash';

    my $hook = sub {
        shift->{$token_name} = {
               map { my $key = $_; my $value;
                     ( $key, sub { defined $value and return $value;
                                   my $flash = $dsl->session($session_hash_key) || {};
                                   $value = delete $flash->{$key};
                                   $dsl->session($session_hash_key, $flash);
                                   return $value;
                               } );
                 } ( keys %{$dsl->session($session_hash_key) || {} })
                               }};
    $dsl->app->add_hook(Dancer2::Core::Hook->new(name => 'before_template_render',
                                                 code => $hook));
};

register_plugin for_versions => [2];

package Dancer2::Plugin::FlashMessage::FakeDSL;

our $AUTOLOAD;
sub AUTOLOAD {
    my $f = (split /::/, $AUTOLOAD)[-1];
    print STDERR " --- $f";
    shift;
    &{"Dancer2::$f"}(@_);
}

1;

__END__

=pod

=head1 NAME

Dancer2::Plugin::FlashMessage - A plugin to display "flash messages" : short temporary messages

=head1 SYNOPSYS

Example with Template Toolkit

In your configuration, make sure you have session configured. Of course you can
use any session engine :

  session: "simple"

In your index.tt view or in your layout :

  <% IF flash.error %>
    <div class=error> <% flash.error %> </div>
  <% END %>

In your css :

  .error { background: #CEE5F5; padding: 0.5em;
           border: 1px solid #AACBE2; }

In your Dancer2 App :

  package MyWebService;

  use Dancer2;
  use Dancer2::Plugin::FlashMessage;

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

By default, the plugin works using a decent configuration. However, you can
change the behaviour of the plugin. See L<CONFIGURATION>

=head1 METHODS

=head2 flash

  # sets the flash message for the warning key
  flash warning => 'some warning message';

  # retrieves and removes the flash message for the warning key
  my $warning_message = flash 'warning';

This method can take 1 or 2 parameters. When called with two parameters, it
sets the flash message for the given key.

When called with one parameter, it returns the value of the flash message of
the given key. The message is deleted from the flash hash in the session.

In both cases, C<flash> always returns the value;

=head1 IN YOUR TEMPLATE

After having set a flash message using C<flash> in your Dancer route, you can
access the flash message from within your template. The plugin provides you
with the C<flash> hashref, that you can access in your template, for example
like this :

  <div class=error> <% flash.error %> </div>

When you use it in your template, the flash message is deleted. So next
time, C<flash.error> will not exist.

=head1 CONFIGURATION

With no configuration whatsoever, the plugin will work fine, thus contributing
to the I<keep it simple> motto of Dancer.

=head2 configuration default values

These are the default values. See below for a description of the keys

  plugins:
    FlashMessage:
      token_name: flash
      session_hash_key: _flash

=head2 configuration description

=over

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

This software is copyright (c) 2011-2012 by Damien "dams" Krotkine <dams@cpan.org>.

=head1 LICENCE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 AUTHORS

This module has been written by Damien "dams" Krotkine <dams@cpan.org>.

=head1 SEE ALSO

L<Dancer2>

=cut
