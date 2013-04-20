#!/usr/bin/env perl
use Modern::Perl;
use Cwd qw/abs_path/;
my $project_dir = abs_path($ARGV[0] // '.');
print join "\n",
    "#!/usr/bin/env perl",
    (map { `cat $_`.';' } grep { -f } split "\n", `find $project_dir/lib -name *.pm`),
    "package main;",
    `tail -n1 $project_dir/multi-exec`;
