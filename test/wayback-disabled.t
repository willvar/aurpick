Test disabling Wayback fallback

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

Mock makepkg to fail verification before any fallback could happen:
  $ cat > "$TESTROOT/bin/makepkg" <<'EOF'
  > #!/bin/bash
  > echo '==> ERROR: Failure while downloading https://dead.example/file.deb' >&2
  > exit 1
  > EOF
  $ chmod +x "$TESTROOT/bin/makepkg"

Mock curl to prove it is never called when fallback is disabled:
  $ cat > "$TESTROOT/bin/curl" <<'EOF'
  > #!/bin/bash
  > echo 'curl should not be called' >&2
  > exit 99
  > EOF
  $ chmod +x "$TESTROOT/bin/curl"

Verification fails immediately without trying Wayback:
  $ PATH="$TESTROOT/bin:$PATH" TESTROOT="$TESTROOT" SCRIPT="$TESTDIR/../aurpick" bash -lc 'cd "$TESTROOT"; source "$SCRIPT"; verify_sources_with_fallback "$TESTROOT/srcdest" false --verifysource; printf "status=%s\n" "$?"' 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
  ==> ERROR: Failure while downloading https://dead.example/file.deb
  status=1

Cleanup:
  $ rm -rf "$TESTROOT"
