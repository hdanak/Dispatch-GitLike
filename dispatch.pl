#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;

my $def_cmd= 'help';
local $0 = ($0 and $0 ne '-') ? basename($0)
                              : die "Multi-exec command called with no basename\n";
my @path = ("/usr/libexec/$0", split ':', $ENV{PATH});
my $cmd = (@ARGV and $ARGV[0] !~ /^-/) ? shift @ARGV : $def_cmd;

# An alias can be a shell command or a subroutine. Note that @ARGV holds
# whatever command-line args were passed, and $0 holds the command basename.
my %alias = (
    help   => sub {
        print "Possible commands:\n", map {"\t$_\n"} find_subcmds();
    },
);

if (exists $alias{$cmd}) {
    if ('CODE' eq ref($alias{$cmd})) {
        exit($alias{$cmd}->())
    } else {
        exec $alias{$cmd}
    }
} else {
    # find the best exec candidate, even with a file extension
    # fall back to the bare command "$base-$cmd"
    for (@path) {
        opendir(my $dh, $_) or next;
        my @files = sort grep {/^$0-$cmd\.?/} readdir $dh;
        closedir $dh;
        exec ("$_/$files[0]", @ARGV) if @files
    }
    exec "$0-$cmd";
}
sub find_subcmds {
    (
        keys(%alias),
        map { m|/$0-([^/]+)$| } map { glob("$_/$0-*") } @path
    )
}
