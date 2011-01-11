use Test::More tests => 4, import => ['!pass'];
use Dancer ':syntax';
use Dancer::Test;

use_ok 'Dancer::Plugin::FlashMessage';

setting views => path('t', 'views');
setting template => 'template_toolkit';

is(flash(foo => 'bar'), 'bar');
is(flash('foo'), 'bar');
is(flash('foo'), undef);
