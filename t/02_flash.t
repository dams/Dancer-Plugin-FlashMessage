use Test::More tests => 4, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

use_ok 'Dancer::Plugin::FlashMessage';

setting views => path('t', 'views');

ok(
    get '/' => sub {
        flash(error => 'plop');
        template 'index', { foo => 'bar' };
    }
);

route_exists [ GET => '/' ];
response_content_like( [ GET => '/' ], qr/foo : bar, message : plop/ );

