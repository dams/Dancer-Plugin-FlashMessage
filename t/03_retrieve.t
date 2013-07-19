
use Test::More tests => 4, import => ['!pass'];
use Dancer2;


{
    package App;
    use Dancer2 ':syntax';
    use Dancer2::Plugin::FlashMessage;

    setting views => path('t', 'views');
    setting template => 'template_toolkit';
    setting session => 'simple';

    get '/set' => sub { my $r = flash(foo => 'bar'); $r };
    get '/get' => sub { my $r = flash('foo'); $r };
}

use Dancer2::Test apps => [ 'App' ];

route_exists [ GET => '/set' ];
response_content_like( [ GET => '/set' ], qr/^bar$/ );
response_content_like( [ GET => '/get' ], qr/^bar$/ );
response_content_like( [ GET => '/get' ], qr/^$/ );
