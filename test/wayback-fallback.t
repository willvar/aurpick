Test Wayback fallback helpers

Setup:
  $ cd "$TESTDIR/.."
  $ export TESTROOT=$(mktemp -d)
  $ mkdir -p "$TESTROOT/bin" "$TESTROOT/srcdest"

Create a PKGBUILD with one unreachable URL, one live URL, and one VCS source:
  $ cat > "$TESTROOT/PKGBUILD" <<'EOF'
  > pkgname=wayback-test
  > pkgver=1
  > pkgrel=1
  > arch=('x86_64')
  > source=(
  >   'recovered.deb::https://dead.example/file.deb'
  >   'https://live.example/still-there.tar.gz'
  >   'git+https://example.org/repo.git'
  > )
  > sha256sums=('SKIP' 'SKIP' 'SKIP')
  > EOF

Mock curl so the dead URL fails live checks and Wayback succeeds on the second CDX candidate:
  $ cat > "$TESTROOT/bin/curl" <<'EOF'
  > #!/bin/bash
  > outfile=""
  > url=""
  > prev=""
  > for arg in "$@"; do
  >   if [[ "$prev" == "-o" ]]; then
  >     outfile="$arg"
  >   fi
  >   prev="$arg"
  >   url="$arg"
  > done
  > case "$*" in
  >   *"-fsIL"*"https://live.example/still-there.tar.gz"*) exit 0 ;;
  >   *"-fsIL"*"https://dead.example/file.deb"*) exit 22 ;;
  >   *"--range 0-0"*"https://dead.example/file.deb"*) exit 22 ;;
  >   *"web.archive.org/cdx/search/cdx"*)
  >     printf '%s\n' '[["timestamp","original","statuscode","mimetype","length"],["20250709091740","https://dead.example/file.deb","200","application/vnd.debian.binary-package","100"],["20250701010101","https://dead.example/file.deb","200","application/vnd.debian.binary-package","100"]]'
  >     exit 0
  >     ;;
  >   *"https://web.archive.org/web/20250709091740id_/https://dead.example/file.deb"*)
  >     exit 22
  >     ;;
  >   *"https://web.archive.org/web/20250701010101id_/https://dead.example/file.deb"*)
  >     printf 'recovered from wayback\n' > "$outfile"
  >     exit 0
  >     ;;
  > esac
  > exit 1
  > EOF
  $ chmod +x "$TESTROOT/bin/curl"

Fallback downloads only the unreachable HTTP source into SRCDEST:
  $ PATH="$TESTROOT/bin:$PATH" TESTROOT="$TESTROOT" SCRIPT="$TESTDIR/../aurpick" bash -lc 'cd "$TESTROOT"; source "$SCRIPT"; try_wayback_source_fallback "$TESTROOT/srcdest"; printf "status=%s\n" "$?"; ls "$TESTROOT/srcdest"; cat "$TESTROOT/srcdest/recovered.deb"' 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
  ==> Source unavailable, checking Wayback: recovered.deb
  ==> Trying Wayback snapshot 1/2: 20250709091740
  ==> Wayback snapshot download failed: 20250709091740
  ==> Trying Wayback snapshot 2/2: 20250701010101
  ==> Recovered source from Wayback: recovered.deb
  status=0
  recovered.deb
  recovered from wayback

Cleanup:
  $ rm -rf "$TESTROOT"
