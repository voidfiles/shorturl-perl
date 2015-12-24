use Test::More;
use Test::Mojo;

# Include application
use FindBin;
require "$FindBin::Bin/../short.pl";

# Allow 302 redirect responses
my $t = Test::Mojo->new;
$t->ua->max_redirects(1);

# Test if the HTML login form exists
$t->get_ok('/kv')
  ->status_is(404);

# Test login with valid credentials
my $resp = $t->post_ok('/' => json => {url => 'http://google.com'})
  ->status_is(200)
  ->json_like('/url' => qr/^http.+$/, 'right value');

$t->get_ok('/' . $resp->tx->res->json->{hash} )
  ->status_is(301)
  ->header_is(Location => "http://www.google.com/");

done_testing();
