package Shorturl::Controller::Test;
use Mojo::Base 'Mojolicious::Controller';
use Shorturl::Utils::Statsd;

sub test {
  my $self = shift;
  Shorturl::Utils::Statsd::timer("test", sub => sub {
    print "This is the function inside\n";
    sleep(1);
    Shorturl::Utils::Statsd::timer("test.testing", sub => sub {
      print "inside the inside\n";
      Shorturl::Utils::Statsd::count("test.testing_awesome");
    });
  });

  Shorturl::Utils::Statsd::timer("test.testing2", sub => sub {
    print "inside the inside\n";
    Shorturl::Utils::Statsd::count("test.testing_awesome2");
  });

  return $self->render(html => "test3");
};

1;
