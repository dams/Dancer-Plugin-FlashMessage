use Test::More tests => 7, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

setting views => path('t', 'views');
setting template => 'template_toolkit';
setting session => 'YAML';

use_ok 'Dancer::Plugin::FlashMessage';

ok(
    get '/set' => sub {
        my $r = flash(foo => 'bar');
        return $r;
    });

ok(
    get '/get' => sub {
        my $r = flash('foo');
        return $r;
    });

route_exists [ GET => '/set' ];
response_content_like( [ GET => '/set' ], qr/^bar$/ );
response_content_like( [ GET => '/get' ], qr/^bar$/ );
response_content_like( [ GET => '/get' ], qr/^$/ );
