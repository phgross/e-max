This directory contains files which are copied to ~/.emacs.d
by scripts/install.sh.

If you add another file here, you will need to update the
install script for ensuring that it first will be checked upon
existance (it will ask the user what should be done if it exists)
and that it will be copied.

The _username.el and _machine.el will be copied to
~/.emacs.d/users/$username.el and ~/.emacs.d/machines/$hostname.el
respectively.

In the init.el, the path to the emacs repository clone will be
substituted.
