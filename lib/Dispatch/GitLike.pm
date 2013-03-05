package Dispatch::GitLike;
use Modern::Perl;
use File::Basename;

sub new {
    my ($class, %opts) = @_;
    my $self = bless {
        default => $opts{default} // 'help',
        alias   => {
            help   => sub {
                my $self = shift;
                print STDERR "Possible commands:\n",
                                map {"\t$_\n"} $self->find_commands();
            },
            %{ $opts{alias} // {} }
        },
        path    => [ split ':', $ENV{PATH} ],
        base    => $opts{base} // (($0 and $0 ne '-') ? basename($0) :
                                die "Error: Cannot resolve command basename.\n"),
    }, $class;
    my @argv = @ARGV;
    $$self{cmd} = (@argv and $argv[0] !~ /^-/) ? shift(@argv) : $$self{default};
    $$self{argv} = \@argv;
    return $self;
}
sub run {
    my ($self, $cmd, $argv) = shift;
    my $alias = $$self{alias};
    $$self{cmd}  = $cmd  // $$self{cmd};
    $$self{argv} = $argv // $$self{argv};
    if (exists $$alias{$cmd}) {
        ('CODE' eq ref($$alias{$cmd})) ? exit($$alias{$cmd}->($self))
                                       : exec($$alias{$cmd}, @$argv)
    } else {
        # Find the best exec candidate, with any file extension.
        for (@$path) {
            opendir(my $dh, $_) or next;
            my @files = sort grep {/^$base-$cmd\.?/} readdir($dh);
            closedir($dh);
            exec("$_/$files[0]", @$argv) if @files
        }
        die "Error: Could not resolve command $base-$cmd.\n";
    }
}
sub commands {
    my $self = shift;
    return (
        keys(%{$$self{alias}}),
        map { m|/$$self{base}-([^/]+)$| } map { glob("$_/$$self{base}-*") } @{$$self{path}}
    )
}

1
