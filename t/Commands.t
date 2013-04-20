use Modern::Perl;
use Test::More;

use Dispatch::GitLike;

#TODO: use unique hash, and test on filesystem as well
my $command = 'UNIQUE_COMMAND_NAME';
my $subcommand = 'UNIQUE_SUBCOMMAND_NAME';
my $dispatch = Dispatch::GitLike->new(
    base => $command,
    commands => {
        $subcommand => sub {
            is @ARGV, 3;
            is $ARGV[0], 'hello';
            is $ARGV[1], 'world';
            is $ARGV[2], '--testing';
            is $0, "$command-$subcommand";
            'bye'
        }
    },
    external => 0
);
is $dispatch->run($subcommand, qw[hello world --testing]), 'bye';

done_testing 6
