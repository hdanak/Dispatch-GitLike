#!/usr/bin/env perl
use Modern::Perl;
use Cwd qw/abs_path/;
my $project_dir = abs_path($ARGV[0] // '.');
print "#!/usr/bin/env perl\n",
    map { (`cat $_`, ";\n") }
    grep { -f }
    split("\n", `find $project_dir/lib -name *.pm`);
print q{
package main;
Dispatch::GitLike->new->run(@ARGV)
};
