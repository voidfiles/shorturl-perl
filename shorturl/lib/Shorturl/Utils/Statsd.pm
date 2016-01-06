package Shorturl::Utils::Statsd;

use strict;
use warnings;

use Time::HiRes;
use Shorturl::Utils::Slowjam;
use Data::Dumper;

sub graphite_timer {
    my $stat = shift;
    my (%args) = @_;
    $args{event} = $stat;
    my $start_time = [ Time::HiRes::gettimeofday ];

    my $slowjam_context = Shorturl::Utils::Slowjam::get_slowjam_context();


    $slowjam_context->event(%args);

    my $end_time = [ Time::HiRes::gettimeofday ];
    my $request_time_ms = Time::HiRes::tv_interval($start_time, $end_time);

    # Record this to statsd
    # if _instance:
    #     _instance.graphite_duration(stat, request_time_ms, prefix)
}

1;
