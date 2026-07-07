Test --version parameter

Setup:
  $ cd "$TESTDIR/.."

Test --version flag outputs hash:
  $ ./aurpick --version
  aurpick \([0-9a-f]{7}\) (re)

Test --version exit code is 0:
  $ ./aurpick --version >/dev/null
  $ echo $?
  0

Test -v short flag also works:
  $ ./aurpick -v
  aurpick \([0-9a-f]{7}\) (re)

Test -v exit code is 0:
  $ ./aurpick -v >/dev/null
  $ echo $?
  0
