Test behavior when downgrade IS installed

Setup - create isolated PATH with downgrade and mock sudo:
  $ cd "$TESTDIR/.."
  $ export TESTBIN=$(mktemp -d)
  $ for cmd in bash sed grep head awk cut tr git pacman fzf makepkg curl; do \
  >   which $cmd >/dev/null 2>&1 && ln -sf $(which $cmd) $TESTBIN/; \
  > done

Create a mock downgrade that just exists:
  $ cat > $TESTBIN/downgrade << 'MOCKEOF'
  > #!/bin/bash
  > echo "Mock downgrade called with: $*"
  > exit 0
  > MOCKEOF
  $ chmod +x $TESTBIN/downgrade

Create a mock sudo that doesn't require password:
  $ cat > $TESTBIN/sudo << 'MOCKEOF'
  > #!/bin/bash
  > # Mock sudo - just execute the command without password
  > shift  # Remove 'sudo' from args
  > exec "$@"
  > MOCKEOF
  $ chmod +x $TESTBIN/sudo

Verify downgrade is available in test PATH:
  $ PATH="$TESTBIN" command -v downgrade >/dev/null 2>&1 && echo "downgrade found"
  downgrade found

Test that official package is detected:
  $ PATH="$TESTBIN" ./aurpick linux 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -1
  ==> \[linux\] is an official repository package, not an AUR package (re)

Test that script invokes downgrade (mock):
  $ PATH="$TESTBIN" ./aurpick firefox 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -3
  ==> \[firefox\] is an official repository package, not an AUR package (re)
  ==> Detected downgrade tool, invoking for you...
  * (re)

Cleanup:
  $ rm -rf $TESTBIN
