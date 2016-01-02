use Mojo::Server::PSGI;
use Plack::Builder;

builder {
  my $server = Mojo::Server::PSGI->new;
  $server->load_app('./script/shorturl');
  $server->app->config(foo => 'bar');
  $server->to_psgi_app;
};
