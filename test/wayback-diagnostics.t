Test Wayback diagnostic messages

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
  > sha256sums=('SKIP')
  > EOF

Snapshot download failures are reported explicitly:
  $ cat > "$TESTROOT/bin/curl" <<'EOF'
  > #!/bin/bash
  > case "$*" in
  >   *"-fsIL"*"https://dead.example/file.deb"*) exit 22 ;;
  >   *"--range 0-0"*"https://dead.example/file.deb"*) exit 22 ;;
  >   *"web.archive.org/cdx/search/cdx"*)
  >     printf '%s\n' '[["timestamp","original","statuscode","mimetype","length"],["20250709091740","https://dead.example/file.deb","200","application/vnd.debian.binary-package","100"]]'
  >     exit 0
  >     ;;
  >   *"https://web.archive.org/web/20250709091740id_/https://dead.example/file.deb"*) exit 22 ;;
  > esac
  > exit 1
  > EOF
  $ chmod +x "$TESTROOT/bin/curl"
  $ PATH="$TESTROOT/bin:$PATH" TESTROOT="$TESTROOT" SCRIPT="$TESTDIR/../aurpick" bash -lc 'cd "$TESTROOT"; source "$SCRIPT"; try_wayback_source_fallback "$TESTROOT/srcdest"; printf "status=%s\n" "$?"' 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
  ==> Source unavailable, checking Wayback: recovered.deb
  ==> Trying Wayback snapshot 1/1: 20250709091740
  ==> Wayback snapshot download failed: 20250709091740
  ==> Wayback has no usable archived copy for: recovered.deb
  status=1

Cleanup:
  $ rm -rf "$TESTROOT"
