package Shorturl::Controller::Create;
use Mojo::Base 'Mojolicious::Controller';
use Shorturl::Schema::URL qw(urlSchema);
use Redis;
use Hashids;

my $hashids = Hashids->new('random');

sub create {
  my $self  = shift;
  my $url   = $self->req->json;
  my $host  = $self->req->url->to_abs->host;
  my $valid = urlSchema()->validate($url);

  if ($valid) {
    my $client      = Redis->new;
    my $new_url_id = $client->incr( 'unique_url_id' );
    my $hash       = $hashids->encode($new_url_id);
    my $url_key    = "url:${new_url_id}";

    $client->set($url_key => $url->{url});

    $self->render(json => {
      url => 'http://' . $host . '/' . $hash,
      hash => $hash
    });

  } else {
    my $errors = {};
    foreach $a ($valid->errors) {
      $errors->{$a->{property}} = $a->{message};
    }

    $self->render(json => $errors);

  }
};

1;
