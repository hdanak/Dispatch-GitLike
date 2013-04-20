use Modern::Perl;
use Test::More;

use Dispatch::GitLike;

Dispatch::GitLike->new(
    path => ['a', 'b', 'c', 'd'],
    commands => {
        subcommand => sub {
            is $ENV{PATH}, 'a:b:c:d';
        }
    },
    external => 0
)->run('subcommand');

done_testing 1
