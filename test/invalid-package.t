Test handling of invalid/non-existent packages

Setup - create isolated PATH with all required dependencies:
  $ cd "$TESTDIR/.."
  $ export TESTBIN=$(mktemp -d)
  $ for cmd in bash sed grep head awk cut tr git fzf makepkg pacman timeout rm mkdir cat; do \
  >   which $cmd >/dev/null 2>&1 && ln -sf $(which $cmd) $TESTBIN/; \
  > done

Test non-existent AUR package (empty repo detected early):
  $ PATH="$TESTBIN" timeout 30 ./aurpick this-package-does-not-exist-12345-test >/dev/null 2>&1
  [1]

Non-existent package should fail (non-zero exit):
  $ PATH="$TESTBIN" timeout 30 ./aurpick nonexistent-pkg-test-xyz >/dev/null 2>&1
  [1]

Cleanup:
  $ rm -rf $TESTBIN
