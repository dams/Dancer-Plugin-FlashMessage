use Test::More tests => 10, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

use_ok 'Dancer::Plugin::FlashMessage';

setting views => path('t', 'views');

ok(
    get '/nothing' => sub {
        template 'div', { };
    });
ok(
    get '/' => sub {
        flash(error => 'plop');
        template 'div', { foo => 'bar' };
    });
ok(
    get '/different' => sub {
        template 'div', { foo => 'bar' };
    }
);

# empty route
route_exists [ GET => '/nothing' ];
response_content_like( [ GET => '/nothing' ], qr/^\n\n$/m );

# first time we get the error message
route_exists [ GET => '/' ];
response_content_like( [ GET => '/' ], qr{<div class=error>plop</div>} );
# second time the error has disappeared
route_exists [ GET => '/different' ];
response_content_like( [ GET => '/different' ], qr/^\n\n$/m );

