use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Crusher');

#Test OpenAPI Definition response
$t->get_ok('/api/v1')->status_is(200)->json_is('/info/title' => 'Crusher');

done_testing();