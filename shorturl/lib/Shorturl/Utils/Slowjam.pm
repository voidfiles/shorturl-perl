package Shorturl::Utils::Slowjam;
use Shorturl::Utils::Slowjam::ProfileGlobalContext;
use Env qw(SLOWJAM_ENABLED);

our $SLOWJAM_PROFILING = !!SLOWJAM_ENABLED;
my $SLOWJAM_CONTEXT = undef;

sub enable_profiling {
    $Shorturl::Utils::Slowjam::SLOWJAM_PROFILING = 1;
}

sub disable_profiling {
    $Shorturl::Utils::Slowjam::SLOWJAM_PROFILING = 0;
}

sub can_profile {
    return !!$Shorturl::Utils::Slowjam::SLOWJAM_PROFILING;
}


sub get_slowjam_context {
    if ($Shorturl::Utils::Slowjam::SLOWJAM_PROFILING) {
        if (!$SLOWJAM_CONTEXT) {
            return Shorturl::Utils::Slowjam::ProfileGlobalContext->new();
        } else {
            return $SLOWJAM_CONTEXT;
        }
    }
}


$SLOWJAM_CONTEXT = get_slowjam_context();

1;
