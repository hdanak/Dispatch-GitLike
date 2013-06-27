package Dispatch::GitLike;
use Modern::Perl;
use File::Basename;

sub new {
    my ($class, %opts) = @_;
    my $path = $opts{path} // [ split ':', $ENV{PATH} ];
    my $base = $opts{base} // (($0 and $0 ne '-') ? basename($0)
                        : die "Error: Cannot resolve command basename.\n");
    my $external = $opts{external} // 1;
    my $default  = $opts{default}  // 'help';
    my $commands = {
        help   => sub {
            my $self = shift;
            print STDERR "Possible commands:\n",
                            map {"\t$_\n"} sort keys %{$$self{commands}};
        },
        ( map {
            my $cmd = $opts{commands}{$_};
            $_ => ref($cmd) ? $cmd : sub { exec($cmd, @ARGV) }
        } keys %{$opts{commands}} ),
        find_external({ base => $base, path => $path })
    };
    # Group subcommands
    my %cmd_groups;
    for (keys %$commands) {
        my @parts = split /-+/;
        if (@parts > 1) {
            push @{$cmd_groups{$parts[0]}},
                [ join('-', @parts[1..$#parts]) => $$commands{$_} ];
            delete $$commands{$_};
        }
    }
    for (keys %cmd_groups) {
        my $subcmd = $_;
        $$commands{$subcmd} = sub {
            Dispatch::GitLike->new(commands => {
                map { @$_ } @{$cmd_groups{$subcmd}}
            })->run(@ARGV);
        }
    }
    my $self = bless {
        external => $external,
        default  => $default,
        commands => $commands,
        path     => $path,
        base     => $base,
    }, $class;
    return $self;
}
sub find_external {
    my ($base, $path) = @{$_[0]}{'base', 'path'};
    map {
        my $cmdpath = $_;
        m|/$base-([^/]+)$| ? (
            ($1 =~ s/\.[^.]+$//r) => sub { exec($cmdpath, @ARGV) }
        ) : ()
    } sort grep { -x } map { glob "$_/$base-*" } ('.', @$path)
}
sub run {
    my ($self, @argv) = @_;
    my $cmd = (@argv and $argv[0] !~ /^-/) ? shift(@argv) : $$self{default};
    die "Error: Could not resolve command '$$self{base} $cmd'.\n"
            unless exists $$self{commands}{$cmd};
    @$self{qw[cmd argv]} = ( $cmd, \@argv );
    local @ARGV = @argv;
    local $0 = "$$self{base}-$cmd";
    local $ENV{PATH} = join ':', @{$$self{path}};
    $$self{commands}{$cmd}->($self)
}

1
