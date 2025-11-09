Test behavior when downgrade is NOT installed

Setup - create isolated PATH without downgrade but with all required deps:
  $ cd "$TESTDIR/.."
  $ export TESTBIN=$(mktemp -d)
  $ for cmd in bash sed grep head awk cut tr git pacman fzf makepkg; do \
  >   which $cmd >/dev/null 2>&1 && ln -sf $(which $cmd) $TESTBIN/; \
  > done

Verify downgrade is not in our test PATH:
  $ PATH="$TESTBIN" command -v downgrade >/dev/null 2>&1
  [1]

Test official package detection without downgrade:
  $ PATH="$TESTBIN" ./aurpick linux 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -4
  ==> \[linux\] is an official repository package, not an AUR package (re)
  ==> Official packages require the downgrade tool (re)
  ==> Please install downgrade first: (re)
    https://github.com/archlinux-downgrade/downgrade

Test exit code should be 1:
  $ PATH="$TESTBIN" ./aurpick firefox >/dev/null 2>&1
  [1]

Cleanup:
  $ rm -rf $TESTBIN
