use Mojolicious::Lite;
use Redis;
use Shorturl::Schema qw(urlSchema);
use Hashids;

my $hashids = Hashids->new('random');

get '/:url_id' => sub {
  my $client    = Redis->new;
  my $c         = shift;
  my $hash      = $c->param('url_id');
  my $unique_id = $hashids->decode($hash);
  my $url       = $client->get("url:" . $unique_id);

  if (!$url) {
    return $c->reply->not_found;
  }

  return $c->redirect_to($url);
};

post '/' => sub {
  my $c     = shift;
  my $url   = $c->req->json;
  my $host  = $c->req->url->to_abs->host;
  my $valid = urlSchema()->validate($url);

  if ($valid) {
    my $client      = Redis->new;
    my $new_url_id = $client->incr( 'unique_url_id' );
    my $hash       = $hashids->encode($new_url_id);
    my $url_key    = "url:${new_url_id}";

    $client->set($url_key => $url->{url});

    $c->render(json => {
      url => 'http://' . $host . '/' . $hash,
      hash => $hash
    });

  } else {
    my $errors = {};
    foreach $a ($valid->errors) {
      $errors->{$a->{property}} = $a->{message};
    }
    $c->render(json => $errors);

  }
};

app->start;
