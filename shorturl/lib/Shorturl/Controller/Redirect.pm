package Shorturl::Controller::Redirect;
use Mojo::Base 'Mojolicious::Controller';
use Redis;
use Hashids;

my $hashids = Hashids->new('random');

sub redirect {
  my $client    = Redis->new;
  my $self      = shift;
  my $hash      = $self->param('url_id');
  my $unique_id = $hashids->decode($hash);
  my $url       = $client->get("url:" . $unique_id);

  if (!$url) {
    return $self->reply->not_found;
  }

  return $self->redirect_to($url);
};

1;
