use Modern::Perl;
use Test::More;

use Dispatch::GitLike;

#TODO: use unique hash to test on filesystem as well
my $command = 'UNIQUE_COMMAND_NAME';
my $subcmd  = 'UNIQUE_SUBCOMMAND_NAME';
my $dispatch = Dispatch::GitLike->new(
    commands    => {
        $subcmd     => sub {
            is @ARGV, 3;
            is $ARGV[0], 'hello';
            is $ARGV[1], 'world';
            is $ARGV[2], '--testing';
            is $0, "$command-$subcmd";
            'bye'
        }
    },
    base        => $command,
    external    => 0
);
is $dispatch->run($subcmd, qw[hello world --testing]), 'bye';

done_testing 6
