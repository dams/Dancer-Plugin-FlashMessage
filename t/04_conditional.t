use Test::More tests => 10, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

use_ok 'Dancer::Plugin::FlashMessage';

setting views => path(setting('confdir'), 't', 'views');
setting template => 'template_toolkit';

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
response_content_is( [ GET => '/nothing' ], '' );
# first time we get the error message
route_exists [ GET => '/' ];
response_content_is( [ GET => '/' ], '<div class=error>plop</div>' );
# second time the error has disappeared
route_exists [ GET => '/different' ];
response_content_is( [ GET => '/different' ], '' );

