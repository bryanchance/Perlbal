######################################################################
# HTTP connection to backend node
# possible states: connecting, bored, sending_req, wait_res, xfer_res
######################################################################

package Perlbal::ManageCommand;
use strict;
use warnings;
use fields (
            'base', # the base command name (like "proc")
            'cmd',
            'ok',
            'err',
            'out',
            'verbose',
            'orig',
            'argn',
            );

sub new {
    my ($class, $base, $cmd, $out, $ok, $err, $orig, $verbose) = @_;
    my $self = fields::new($class);

    $self->{base} = $base;
    $self->{cmd}  = $cmd;
    $self->{ok}   = $ok;
    $self->{err}  = $err;
    $self->{out}  = $out;
    $self->{orig} = $orig;
    $self->{verbose} = $verbose;
    $self->{argn}    = [];
    return $self;
}

sub out   { my $mc = shift; return @_ ? $mc->{out}->(@_) : $mc->{out}; }
sub ok    { my $mc = shift; return $mc->{ok}->(@_);  }
sub err   { my $mc = shift; return $mc->{err}->(@_); }
sub cmd   { my $mc = shift; return $mc->{cmd};       }
sub orig  { my $mc = shift; return $mc->{orig};      }
sub end   { my $mc = shift; $mc->{out}->(".");    1; }
sub verbose { my $mc = shift; return $mc->{verbose}; }

sub parse {
    my $mc = shift;
    my $regexp = shift;
    my $usage = shift;

    my @ret = ($mc->{cmd} =~ /$regexp/);
    $mc->parse_error($usage) unless @ret;

    my $i = 0;
    foreach (@ret) {
        $mc->{argn}[$i++] = $_;
    }
    return $mc;
}

sub arg {
    my $mc = shift;
    my $n = shift;   # 1-based array, to correspond with $1, $2, $3
    return $mc->{argn}[$n - 1];
}

sub args {
    my $mc = shift;
    return @{$mc->{argn}};
}

sub parse_error {
    my $mc = shift;
    my $usage = shift;

    die $usage || "Invalid syntax to '$mc->{base}' command\n"
}

sub no_opts {
    my $mc = shift;
    die "The '$mc->{base}' command takes no arguments\n"
        unless $mc->{cmd} eq $mc->{base};
    return $mc;
}

1;

# Local Variables:
# mode: perl
# c-basic-indent: 4
# indent-tabs-mode: nil
# End:
