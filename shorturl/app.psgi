use Mojo::Server::PSGI;
use Plack::Middleware::AccessLog::Timed;
use Plack::Builder;

use lib './lib';
use Shorturl::Middleware::Slowjam;

builder {
  my $server = Mojo::Server::PSGI->new;
  $server->load_app('./script/shorturl');
  $server->app->config(foo => 'bar');
  $app = $server->to_psgi_app;
  $app = Shorturl::Middleware::Slowjam->wrap($app, %options);
  $app = Plack::Middleware::AccessLog::Timed->wrap($app, format => "%v %h %l %u %t \"%r\" %>s %b %D");
};
