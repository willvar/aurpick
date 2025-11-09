Basic functionality tests for aurpick

Setup:
  $ cd "$TESTDIR/.."

Test script syntax is valid:
  $ bash -n aurpick
  $ echo $?
  0

Test help message when no argument provided:
  $ ./aurpick 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -2
  ==> Usage: .*/aurpick \[--dev\] <package-name> (re)
  Example: .*/aurpick yay (re)

Test exit code for no argument:
  $ ./aurpick >/dev/null 2>&1
  [1]

Test missing dependencies detection:
  $ export TESTBIN=$(mktemp -d)
  $ ln -sf $(which bash) $TESTBIN/
  $ PATH="$TESTBIN" ./aurpick yay 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -1
  ==> Missing dependencies:.* (re)
  $ rm -rf $TESTBIN
