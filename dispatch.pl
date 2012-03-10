#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

my $default = 'help';  # set this to the command to run if one isn't provided
my $fallback = 'git';  # set this to your program's actual name
local $0 = ($0 and $0 ne '-') ? basename($0) : $fallback;
my $prefix = "/usr/libexec/$0";  # set this to where the target binaries live
my $command = $default;
if (@ARGV and $ARGV[0] !~ /^-/) {
    $command = shift @ARGV;
}

# Set your aliases here, or maybe import it from a config file. Values should
# be either a command to run, or a perl subroutine, with the command-line args
# passed in. The args will not be appended if the string value ends in
# a newline. It is up to you to insert $0 or "$prefix/$0-" if desired.
my %alias = (
# e.g.
#    help   => "echo 'rtfm'\n"  # runs "echo 'rtfm'"
#    stat   => "$0 status"  # runs "/usr/libexec/git status args..."
#    access => sub { die "Access Denied!\n" if $_[0] != 'secret' }
);

my $exec_cmd;
if (exists $alias{$command}) {
    if ('CODE' eq ref($alias{$command})) {
        exit($alias{$command}->(@ARGV))
    } elsif (chomp $alias{$command}) {
        $exec_cmd = $alias{$command}
    } else {
        $exec_cmd = "$alias{$command} @ARGV"
    }
} else {
    $exec_cmd = "$prefix/$0-$command @ARGV"
}

exec $exec_cmd;
