package Dispatch::GitLike;
use Modern::Perl;
use File::Basename;

sub new {
    my ($class, %opts) = @_;
    my @path = defined($opts{path}) ? @{$opts{path}} : split(':', $ENV{PATH});
    my $base = $opts{basecmd} // ( ($0 and $0 ne '-') ? basename($0)
                           : die "Error: Cannot resolve command basename.\n" );
    my $self = bless {
        default  => $opts{default} // 'help',
        commands => {
            help   => sub {
                my $self = shift;
                print STDERR "Possible commands:\n",
                                map {"\t$_\n"} keys %{$$self{commands}};
            },
            %{ $opts{commands} // {} },
            map {
                my $cmdpath = $_;
                m|/$base-([^/]+)$| ? ( $1 => sub {
                    my $self = shift;
                    exec($cmdpath, @{$$self{argv}})
                } ) : ()
            } sort grep { -x } map { glob "$_/$base-*" } @path
        },
        path    => \@path,
        base    => $base,
    }, $class;
    return $self;
}
sub run {
    my ($self, @argv) = shift;
    my $cmd = (@argv and $argv[0] !~ /^-/) ? shift(@argv) : $$self{default};
    die "Error: Could not resolve command '$$self{base} $cmd'.\n"
            unless exists $$self{commands}{$cmd};
    @$self{qw[cmd argv]} = ( $cmd, \@argv );
    local @ARGV = @argv;
    local $0 = "$self{base}-$cmd";
    local $ENV{PATH} = $self{path};
    exit($$self{commands}{$cmd}->($self))
}

1
