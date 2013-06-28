Name
====
Dispatch::GitLike

Description
===========
Dispatch::GitLike is a module for building command tool-chains in a manner similar to `git`.

Synopsis
========

### Quick and Dirty

    > ln -s mycmd `which multi-exec`
    > echo "echo 'echooo..'" > mycmd-action && chmod +x mycommand-action
    > mycmd
    Possible commands:
            help
            action
    > mycmd action
    echooo..
    > ln -s mycmd-branch `which multi-exec`
    > ... create executable 'mycmd-branch-subaction' ...
    > mycmd branch subaction --key=val -o 1
    ... calls mycmd-branch-subaction --key=val -o 1 ...

### Or as a Module

    use Dispatch::GitLike;
    Dispatch::GitLike->new(
        commands => {
            mycmd => sub {
                ...custom subcommand...
            }
        }
    )->run(@ARGV)

Installation
============

    cpanm git://github.com/hdanak/Dispatch-GitLike.git

Usage
=====
Dispatch::GitLike has two modes of operation:

Symlink `multi-exec`
-------------------
Symlink or rename the standalone `multi-exec` binary to your command's base-name (e.g. `git`), then add executable files named `<base>-<cmd>` to a `$PATH`-accessible directory.  The script will automatically find and dispatch the correct script.  A self-contained version of the `multi-exec` script is included for use without full installation.

Create your own Dispatch Script
-------------------------------
The easiest way to create your own Dispatch script is to simply copy the included multi-exec wrapper script and customize it by providing options to the `new` method. Here are the available options along with their defaults:

### `new` ###
        Dispatch::GitLike->new(
            path      => "..."    // $ENV{PATH},    # custom PATH to search for subcommands
            base      => "..."    // basename($0),  # name to use to search for subcommands
            default   => "..."    // 'help',        # default subcommand to execute
            commands  => {                          # extra commands to dispatch before external commands
                action => sub {
                    my ($self) = @_;
                    ...@ARGV, $0, and $ENV{PATH} locally set...
                }
            }
            external    =>  (0|1)   // 1            # whether to search for external commands as well
        )

Subroutines in the 'commands' hashref are called with localized @ARGV, $0, and $ENV{PATH} reflecting the conditions in which the command was called. The Dispatch::GitLike object is also passed as the first argument. Note that the executable `PATH` is searched when `new` is called, rather than during dispatch time.
