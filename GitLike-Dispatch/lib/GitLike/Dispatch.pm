package GitLike::Dispatch;
use Modern::Perl;
use File::Basename;
use Scalar::Util qw/refaddr/;

our %objects;

sub new {
    my ($class, %opts) = @_;
    my $self = {};
    $objects{refaddr $self} = {
        default => $opts{default} // 'help',
        alias   => {
            help   => sub {
                my $self = shift;
                print "Possible commands:\n", map {"\t$_\n"} $self->find_commands();
            },
            %{$opts{alias} // {}}
        },
        options => {
            help    => qr/--help|-h/,
            %{$opts{options} // {}}
        },
        path    => [ split ':', $ENV{PATH} ],
    };
    bless $self, $class;
}
sub run {
    my $self = $objects{refaddr $_[0]};
    my ($alias, $path, $base, $cmd, $argv) = @$self{qw[ alias path basename cmd argv ]};
    if (exists $$alias{$cmd}) {
        if ('CODE' eq ref($$alias{$cmd})) {
            exit($$alias{$cmd}->($_[0]))
        } else {
            exec $$alias{$cmd}, @$argv;
        }
    } else {
        # Find the best exec candidate, with any file extension.
        for (@$path) {
            opendir(my $dh, $_) or next;
            my @files = sort grep {/^$base-$cmd\.?/} readdir $dh;
            closedir $dh;
            exec ("$_/$files[0]", @$argv) if @files
        }
        die "Error: Could not resolve command $base-$cmd.\n";
    }
}
sub resolve {
    my $self = $objects{refaddr $_[0]};
    $$self{basename} = ($0 and $0 ne '-') ? basename($0)
                                          : die "Error: Cannot resolve command basename.\n";
    if (@ARGV and $ARGV[0] !~ /^-/) {
        $$self{command} = $ARGV[0];
        $$self{argv} = @ARGV[1 .. $#ARGV];
    } else {
        $$self{command} = $$self{default};
        $$self{argv} = @ARGV;
    }
}
sub find_commands {
    my $self = $objects{refaddr $_[0]};
    return (
        keys(%{$$self{alias}}),
        map { m|/$$self{basename}-([^/]+)$| } map { glob("$_/$$self{basename}-*") } @{$$self{path}}
    )
}

1
