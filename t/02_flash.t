
use Test::More tests => 6, import => ['!pass'];
use Dancer2;

{
    package App;
    use Dancer2 ':syntax';
    use Dancer2::Plugin::FlashMessage;

    setting views   => path('t', 'views');
    setting session => 'YAML';

    get '/nothing'   => sub {  template 'index', { }; };
    get '/'          => sub {  flash(error => 'plop');  template 'index', { foo => 'bar' }; };
    get '/different' => sub {  template 'index', { foo => 'bar' }; };
}

use Dancer2::Test apps => [ 'App' ];

# empty route
route_exists [ GET => '/nothing' ];
response_content_like( [ GET => '/nothing' ], qr/foo :\s*, message :\s*$/ );

# first time we get the error message
route_exists [ GET => '/' ];
response_content_like( [ GET => '/' ], qr/foo : bar, message : plop$/ );
# second time the error has disappeared
route_exists [ GET => '/different' ];
response_content_like( [ GET => '/different' ], qr/foo : bar, message : \s*$/ );

