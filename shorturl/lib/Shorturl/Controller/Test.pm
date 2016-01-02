package Shorturl::Controller::Test;
use Mojo::Base 'Mojolicious::Controller';

sub test {
  my $self = shift;
  return $self->render(text => "test3");
};

1;
