Test --version parameter

Setup:
  $ cd "$TESTDIR/.."

Test --version flag outputs correct version:
  $ ./aurpick --version
  aurpick version 1.0.0

Test --version exit code is 0:
  $ ./aurpick --version >/dev/null
  $ echo $?
  0

Test -v short flag also works:
  $ ./aurpick -v
  aurpick version 1.0.0

Test -v exit code is 0:
  $ ./aurpick -v >/dev/null
  $ echo $?
  0
