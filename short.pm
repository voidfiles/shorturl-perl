use Mojolicious::Lite;
use Redis;
use Shorturl::Schema qw(urlSchema);

get '/' => sub {
  my $c    = shift;
  my $host = $c->req->url->to_abs->host;
  my $ua   = $c->req->headers->user_agent;
  $c->render(text => 'I ♥ Mojolicious!');
};

post '/' => sub {
  my $c      = shift;
  my $valid  = urlSchema()->validate($c->req->json);
  if ($valid) {
    $c->render(text => 'I ♥ Mojolicious!');
    # do something interesting here with $dt...
  } else {
    my $errors = {};
    foreach $a ($valid->errors) {
      $errors->{$a->{property}} = $a->{message};
    }
    $c->render(json => $errors);
  }
};

app->start;
