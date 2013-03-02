GitLike::Dispatch
=================
GitLike::Dispatch is a module for creating extendible command tool-chains, in
a style similar to the `git` command (i.e. `git add` will dispatch `git-add`).
The simplest usage is to symlink the `multi-exec` script to the desired
command name, which will automatically find and dispatch the correct script.
A self-contained version of the `multi-exec` script is included for use
without full installation.

Basic Usage
-----------
### multi-exec script ###
Rename or symlink `multi-exec` script to your command's base name (e.g. git),
and optionally add aliases or modify the search path.

For instance:

    > ln -s multi-exec ~/.local/bin/mytool
    > chmod +x ~/.local/bin/mytool
    > ... add executable ~/.local/bin/mytool-cmd ...
    > mytool cmd --arg=val ...      # calls mytool-cmd --arg=val ...
