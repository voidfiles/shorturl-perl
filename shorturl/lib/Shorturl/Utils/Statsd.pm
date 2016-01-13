package Shorturl::Utils::Statsd;

use strict;
use warnings;

use Time::HiRes;
use Shorturl::Utils::Slowjam;
use Net::Statsd;

sub timer {
    my $stat = shift;
    my (%args) = @_;
    $args{event} = $stat;
    my $start_time = [ Time::HiRes::gettimeofday ];

    my $slowjam_context = Shorturl::Utils::Slowjam::get_slowjam_context();

    $slowjam_context->event(%args);

    my $end_time = [ Time::HiRes::gettimeofday ];
    my $interval = Time::HiRes::tv_interval( $start_time ) * 1000; # ms

    Net::Statsd::timing($stat, $interval);
}

sub count {
    my $stat = shift;
    my (%args) = @_;
    $args{event} = $stat;
    my $slowjam_context = Shorturl::Utils::Slowjam::get_slowjam_context();
    $slowjam_context->mark(%args);

    Net::Statsd::increment($stat);
}

1;
