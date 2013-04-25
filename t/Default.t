use Modern::Perl;
use Test::More;

use Dispatch::GitLike;

Dispatch::GitLike->new(
    commands    => {
        subcommand => sub { pass }
    },
    default     => 'subcommand',
    external    => 0
)->run();

done_testing 1
