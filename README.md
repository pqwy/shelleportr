
## shelleportr ##

A small utility similar to [autojump](https://github.com/joelthelion/autojump).

**shelleportr**'s advantage is speed: with **autojump**, registering the current
directory takes around 80ms on my computer. With **shelleportr**, it takes 4ms -
fast enough for me not to notice.

# installation #

`configure`, `make`, `make install`, or just copy the resulting binary
somewhere.

Have the commands from the provided `shelleportr.bash` run as part of shell
initialization, for example by sourcing the file from `~/.bashrc`,
`/etc/bash.bashrc` or similar.

# use #

`j <PATTERN>`.

Run `shelleportr --help` for arguments to the binary itself. In normal use,
`shelleportr` is invoked from `$PROMPT_COMMAND` to keep tabs on which
directories you frequent most often, and the `j` shell function searches this
database and changes the current directory if a result is found.

# todo #

* A fancier match algorithm? Although main use is just searching for a
  distinctive substring of the desired directory's basename.

* Score aging.

* Dead directory prunning.

