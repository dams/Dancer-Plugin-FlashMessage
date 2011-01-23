use Test::More tests => 7, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

setting views => path('t', 'views');

# load the plugin with persistence enabled
setting('plugins', { FlashMessage => { persistence => 1 } });
use_ok 'Dancer::Plugin::FlashMessage';

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

# first time we get the error message
route_exists [ GET => '/' ];
response_content_like( [ GET => '/' ], qr/foo : bar, message : plop$/ );
# second time the error is still there, thanks to persistence
route_exists [ GET => '/different' ];
response_content_like( [ GET => '/different' ], qr/foo : bar, message : plop$/ );

