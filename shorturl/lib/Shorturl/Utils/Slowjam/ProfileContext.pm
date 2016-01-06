package Shorturl::Utils::Slowjam::ProfileContext;

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw(time);

sub new {
  my $class = shift;
  my (%args) = @_;
  $args{event} //= undef;
  $args{should_show} //= 1;

  $args{is_marker} //= 0;
  $args{start_time} //= time();
  if (!$args{stop_time}) {
    if ($args{is_marker}) {
      $args{stop_time} = $args{start_time};
    } else {
      $args{stop_time} = undef;
    }
  }

  $args{fmt} //= undef;
  $args{tag} //= undef;
  $args{extras} //= {};
  $args{inner_events} = [];

  return bless({%args}, $class);
}

sub from_hash {
    my $class = shift;
    my (%args) = @_;

    my $obj = new( @_ );

    my $inner_events = [];

    foreach my $child (@{ $args{inner_events} }) {
      push($inner_events, $child->from_hash(%{ $child }));
    }

    $obj->{inner_events} = $inner_events;

    return $obj;
}

sub stop {
  my ($self) = @_;
  if (!$self->{is_marker}) {
    $self->{stop_time} = time();
  }
}

sub execution_time {
  my ($self) = @_;
  if ($self->{stop_time}) {
    return ($self->{stop_time} - $self->{start_time}) * 1000;
  }
}

sub pretty_execution_time {
    my ($self) = @_;
    my $et = $self->execution_time();

    if ($et) {
      return sprintf('(+%5d ms)', $et);
    }

    return '(  running)';
}

sub render_event {
    my ($self, $epoch, $indent) = @_;

    $indent //= 0;
    $epoch //= $self->{start_time};
    my $indented = '';
    for (my $i=0; $i <= $indent; $i++) {
       $indented = ' |' . $indented;
    }

    #         '(+50000 ms)'
    my $pad = '           ';

    if (!$self->{stop_time}) {
      $self->{stop_time} = $self->{start_time};
      $pad = '   BONED   ';
    }

    my $offset = sprintf('%8d ms', ($self->{start_time} - $epoch) * 1000);
    my $formatted_extras = '';

    if (%{ $self->{extras} }) {
        foreach my $key (sort { $self->{extras}{$b} cmp $self->{extras}{$a} } keys %{ $self->{extras} }) {
            my $val = $self->{extras}{$key};
            $formatted_extras = $formatted_extras . "$key=$val ";
        }

        $formatted_extras = " [" . $formatted_extras . "]";
    } elsif ($self->{fmt}) {
        $formatted_extras = join('', [' [', $self->{fmt}, ']']);
    }

    my $fmt = '%s %s%s %s %s%s';
    my $rv;

    if ($self->{is_marker}) {
        $rv = [sprintf($fmt, $offset, $pad, $indented, '@', $self->{event}, $formatted_extras)];
    } elsif (!@{ $self->{inner_events} }) {
        $rv = [sprintf($fmt, $offset, $self->pretty_execution_time(), $indented, '=', $self->{event}, $formatted_extras)];
    } else {
        $rv = [sprintf($fmt, $offset, $pad, $indented, '+', $self->{event}, $formatted_extras)];
    }

    if (@{ $self->{inner_events} }) {
        foreach my $child (@{ $self->{inner_events} }) {

          if ($child->{should_show}) {
            push($rv, @{ $child->render_event($epoch, $indent + 1) });
          }
        }

        push($rv, sprintf('%s %s%s +', $pad, $self->pretty_execution_time(), $indented));
    }

    return $rv;
}

sub render_event_for_console {
  my ($self) = @_;
  my $output = $self->render_event();
  my $header = ['       time   exec time event', '----------- ----------- ------------------------------'];
  push($header, @{ $output });
  return "\n" . join("\n", @{ $header }) . "\n";
}

sub to_hash {
  my $self = shift;

  my $inner_events = [];

  foreach my $child (@{ $self->{inner_events} }) {
    push($inner_events, $child->to_hash());
  }

  return {
      event => $self->{event},
      start_time => $self->{start_time},
      stop_time => $self->{stop_time},
      is_marker => $self->{is_marker},
      fmt => $self->{fmt},
      tag => $self->{tag},
      extras => $self->{extras},
      inner_events => $inner_events
  };
}

1;
