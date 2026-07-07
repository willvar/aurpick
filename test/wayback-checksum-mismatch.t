Test Wayback fallback rejects checksum mismatches

Setup:
  $ cd "$TESTDIR/.."
  $ export TESTROOT=$(mktemp -d)
  $ mkdir -p "$TESTROOT/bin" "$TESTROOT/srcdest"

Create a PKGBUILD with one unreachable HTTP source:
  $ cat > "$TESTROOT/PKGBUILD" <<'EOF'
  > pkgname=wayback-test
  > pkgver=1
  > pkgrel=1
  > arch=('x86_64')
  > source=('recovered.deb::https://dead.example/file.deb')
  > sha256sums=('not-a-real-sum')
  > EOF

Mock curl so Wayback recovery succeeds:
  $ cat > "$TESTROOT/bin/curl" <<'EOF'
  > #!/bin/bash
  > outfile=""
  > prev=""
  > for arg in "$@"; do
  >   if [[ "$prev" == "-o" ]]; then
  >     outfile="$arg"
  >   fi
  >   prev="$arg"
  > done
  > case "$*" in
  >   *"-fsIL"*"https://dead.example/file.deb"*) exit 22 ;;
  >   *"--range 0-0"*"https://dead.example/file.deb"*) exit 22 ;;
  >   *"web.archive.org/cdx/search/cdx"*)
  >     printf '%s\n' '[["timestamp","original","statuscode","mimetype","length"],["20250709091740","https://dead.example/file.deb","200","application/vnd.debian.binary-package","100"]]'
  >     exit 0
  >     ;;
  >   *"https://web.archive.org/web/20250709091740id_/https://dead.example/file.deb"*)
  >     printf 'recovered from wayback\n' > "$outfile"
  >     exit 0
  >     ;;
  > esac
  > exit 1
  > EOF
  $ chmod +x "$TESTROOT/bin/curl"

Mock makepkg so initial verification fails from missing source and retry fails from checksum mismatch:
  $ cat > "$TESTROOT/bin/makepkg" <<'EOF'
  > #!/bin/bash
  > if [[ -f "$SRCDEST/recovered.deb" ]]; then
  >   echo '    recovered.deb ... FAILED' >&2
  >   echo '==> ERROR: One or more files did not pass the validity check!' >&2
  >   exit 1
  > fi
  > echo '==> ERROR: Failure while downloading https://dead.example/file.deb' >&2
  > exit 1
  > EOF
  $ chmod +x "$TESTROOT/bin/makepkg"

Verification still fails after recovery when checksum validation rejects the archived file:
  $ PATH="$TESTROOT/bin:$PATH" TESTROOT="$TESTROOT" SCRIPT="$TESTDIR/../aurpick" bash -lc 'cd "$TESTROOT"; source "$SCRIPT"; verify_sources_with_fallback "$TESTROOT/srcdest" true --verifysource; printf "status=%s\n" "$?"; ls "$TESTROOT/srcdest"; cat "$TESTROOT/srcdest/recovered.deb"' 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
  ==> ERROR: Failure while downloading https://dead.example/file.deb
  ==> Source verification failed
  ==> Source unavailable, checking Wayback: recovered.deb
  ==> Trying Wayback snapshot 1/1: 20250709091740
  ==> Recovered source from Wayback: recovered.deb
  ==> Retrying source verification with recovered files...
      recovered.deb ... FAILED
  ==> ERROR: One or more files did not pass the validity check!
  ==> Integrity check failed for:
  ==>   - recovered.deb
  status=1
  recovered.deb
  recovered from wayback

Cleanup:
  $ rm -rf "$TESTROOT"
