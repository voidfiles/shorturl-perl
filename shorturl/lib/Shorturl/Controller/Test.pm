package Shorturl::Controller::Test;
use Mojo::Base 'Mojolicious::Controller';
use Shorturl::Utils::Statsd;

sub test {
  my $self = shift;
  Shorturl::Utils::Statsd::graphite_timer("test", sub => sub {
    print "This is the function inside\n";
    sleep(1);
    Shorturl::Utils::Statsd::graphite_timer("test.testing", sub => sub {
      print "inside the inside\n";
    });
  });

  Shorturl::Utils::Statsd::graphite_timer("test.testing2", sub => sub {
    print "inside the inside\n";
  });

  return $self->render(text => "test3");
};

1;
