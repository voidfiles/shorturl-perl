package Shorturl::Utils::Slowjam::ProfileGlobalContext;

use strict;
use warnings;
use Shorturl::Utils::Slowjam::ProfileContext;
use Data::Dumper;

sub new {
  my ($class, %args) = @_;
  my $args = \%args;
  $args->{_started} = 0;
  $args->{_stack} = [];
  return bless($args, $class);
}

sub start {
    my ($self, $event, $fmt, $extras, $tag) = @_;
    if (!$Shorturl::Utils::Slowjam::SLOWJAM_PROFILING) {
        return;
    }

    $self->{_started} = 1;
    $self->{_stack} = [Shorturl::Utils::Slowjam::ProfileContext->new(event => $event, fmt => $fmt, extras => $extras, tag => $tag)];
}

sub stop {
    my ($self) = @_;
    if (!$Shorturl::Utils::Slowjam::SLOWJAM_PROFILING) {
        return;
    }
    my $profile;

    if ($self->{_stack}) {
      $profile = $self->{_stack}[0];
    }


    $self->{started} = 0;
    $self->{_stack} = [];

    if ($profile) {
        $profile->stop();
        return $profile;
    }
}

sub push {
    my $self = shift;
    my (%args) = @_;
    if (!$self->profiling()) {
        return;
    }

    my $profile = Shorturl::Utils::Slowjam::ProfileContext->new(%args);
    CORE::push($self->{_stack}[-1]->{inner_events}, $profile);
    CORE::push($self->{_stack}, $profile);

    return $profile;
}

sub pop {
    my $self = shift;
    if (!$self->profiling()) {
        return;
    }

    my $profile = CORE::pop($self->{_stack});
    $profile->stop();
}

sub  event {
    my $self = shift;
    my (%args) = @_;
    my $sub   = $args{sub};
    my $child = $self->push(%args);

    if ($child) {
        $sub->($child->{extras});
        $self->pop();
    } else {
        $sub->({});
    }
}

sub mark {
    my ($self, $event, $fmt, $extras, $tag) = @_;
    if (!$self->profiling()) {
        return;
    }

    my $profile = Shorturl::Utils::Slowjam::ProfileContext->new(event => $event, fmt => $fmt, extras => $extras, tag => $tag, is_marker => 1);
    CORE::push($self->{_stack}[-1]->{inner_events}, $profile);
}

sub profiling {
    my ($self) = @_;
    return $Shorturl::Utils::Slowjam::SLOWJAM_PROFILING && $self->{_started};
}


1;
