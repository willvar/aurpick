Test --dev parameter functionality

Setup:
  $ cd "$TESTDIR/.."

Test --dev parameter is accepted and shows dev mode message:
  $ timeout 5 ./aurpick --dev nonexistent-pkg-xyz 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep -E "(Dev mode|temporary files will be preserved)"
  ==> Dev mode: temporary files will be preserved in /tmp/aurpick-nonexistent-pkg-xyz

Test that script continues after dev mode message (verifies --dev doesn't exit early):
  $ timeout 5 ./aurpick --dev another-nonexistent-pkg 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -3 | grep -c "==>"
  [23] (re)

Test --dev with missing package name still shows usage error:
  $ ./aurpick --dev 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | head -1
  ==> Usage: .*/aurpick .* <package-name> (re)

Test --dev with missing package exits with code 1:
  $ ./aurpick --dev >/dev/null 2>&1
  [1]
