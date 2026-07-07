Test deferred checksum prompt behavior

Setup:
  $ cd "$TESTDIR/.."

Successful verification does not ask about skipping checksums:
  $ SCRIPT="$TESTDIR/../aurpick" bash -lc 'source "$SCRIPT"; confirm() { echo called; return 0; }; verify_sources_with_fallback() { LAST_INTEGRITY_FAILURE=false; return 0; }; makepkg_flags=(-si); verify_flags=(--verifysource); prepare_sources_for_build /tmp true makepkg_flags verify_flags; printf "status=%s\nflags=%s\nverify=%s\n" "$?" "${makepkg_flags[*]}" "${verify_flags[*]}"'
  status=0
  flags=-si
  verify=--verifysource

Checksum prompt appears only after integrity failure and can enable skipchecksums:
  $ SCRIPT="$TESTDIR/../aurpick" bash -lc 'source "$SCRIPT"; attempts=0; confirm() { echo "PROMPT:$1"; return 0; }; verify_sources_with_fallback() { attempts=$((attempts + 1)); if [[ $attempts -eq 1 ]]; then LAST_INTEGRITY_FAILURE=true; return 1; fi; LAST_INTEGRITY_FAILURE=false; return 0; }; makepkg_flags=(-si); verify_flags=(--verifysource); prepare_sources_for_build /tmp true makepkg_flags verify_flags; printf "status=%s\nflags=%s\nverify=%s\nattempts=%s\n" "$?" "${makepkg_flags[*]}" "${verify_flags[*]}" "$attempts"' | sed 's/\x1b\[[0-9;]*m//g'
  PROMPT:Skip all checksum verification and continue?
  ==> Will use --skipchecksums flag
  status=0
  flags=--skipchecksums -si
  verify=--verifysource --skipchecksums
  attempts=2
