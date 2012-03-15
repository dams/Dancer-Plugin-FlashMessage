use Test::More tests => 10, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

setting views => path('t', 'views');
setting template => 'template_toolkit';
setting session => 'YAML';

use_ok 'Dancer::Plugin::FlashMessage';

ok(
    get '/nothing' => sub {
        template 'index', { };
    });
ok(
    get '/' => sub {
        flash(error => 'plop');
        template 'index', { foo => 'bar' };
    });
ok(
    get '/different' => sub {
        template 'index', { foo => 'bar' };
    }
);

# empty route
# route_exists [ GET => '/nothing' ];
response_content_like( [ GET => '/nothing' ], qr/foo :\s*, message :\s*$/ );

# first time we get the error message
# route_exists [ GET => '/' ];
response_content_like( [ GET => '/' ], qr/foo : bar, message : plop$/ );
# second time the error has disappeared
# route_exists [ GET => '/different' ];
response_content_like( [ GET => '/different' ], qr/foo : bar, message : \s*$/ );

