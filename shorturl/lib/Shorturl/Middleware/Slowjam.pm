package Shorturl::Middleware::Slowjam;
use parent qw( Plack::Middleware );
use Plack::Util::Accessor 'logger';
use Plack::Request;
use Shorturl::Utils::Slowjam;
use Data::Dumper;

sub call {
    my($self, $env) = @_;
    my $slowjam_context = Shorturl::Utils::Slowjam::get_slowjam_context();
    # Do something with $env
    my $req = Plack::Request->new($env);

    if ($slowjam_context) {
      $extras = {
          'host'        => $env->{HTTP_HOST},
          'ip'          => $req->address,
          'method'      => $req->method,
          'uri'         => '' . $req->uri,
      };
      $slowjam_context->start('request', extras => $extras);
    }

    # $self->app is the original app
    my $res = $self->app->($env);

    if ($slowjam_context) {
      my $profile = $slowjam_context->stop();
      if ($profile) {
        print "rendering event\n";
        $profile->render_event_for_console();
        print "\n";
      }
    }
    # Do something with $res
    return $res;
}

1;
