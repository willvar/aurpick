Historical version metadata security tests

Setup:
  $ cd "$TESTDIR/.."
  $ . ./aurpick

Parse complete .SRCINFO version metadata:
  $ parse_srcinfo_version $'pkgbase = demo\n\tpkgver = 1.2.3\n\tpkgrel = 4\n\tepoch = 2'
  2:1.2.3-4

Accept pkgver characters supported by makepkg:
  $ parse_srcinfo_version $'pkgbase = demo\n\tpkgver = 1.0~rc1\n\tpkgrel = 2'
  1.0~rc1-2

Reject an invalid pkgrel with multiple subrelease levels:
  $ parse_srcinfo_version $'pkgbase = demo\n\tpkgver = 1.2.3\n\tpkgrel = 1.2.3'
  ?

Message output does not interpret backslash escapes from version metadata:
  $ output=$(info 'version: 1\e]0;title\a')
  $ [[ "$output" == *'1\e]0;title\a' ]]

Empty .SRCINFO does not consume subsequent input:
  $ printf 'next-line\n' | { parse_srcinfo_version ""; IFS= read -r line; printf '%s\n' "$line"; }
  ?
  next-line

Missing or invalid metadata is not evaluated or displayed:
  $ parse_srcinfo_version $'pkgbase = demo\n\tpkgver = $(touch /tmp/aurpick-srcinfo-pwned)\n\tpkgrel = 1'
  ?
  $ test ! -e /tmp/aurpick-srcinfo-pwned

Historical PKGBUILD code is never executed while loading versions:
  $ REPO=$(mktemp -d)
  $ MARKER="$REPO/pwned"
  $ git -C "$REPO" init -q
  $ git -C "$REPO" config user.email test@example.com
  $ git -C "$REPO" config user.name test
  $ printf 'pkgver=1.0\npkgrel=1\n' > "$REPO/PKGBUILD"
  $ printf 'pkgbase = demo\n\tpkgver = 1.0\n\tpkgrel = 1\n' > "$REPO/.SRCINFO"
  $ git -C "$REPO" add PKGBUILD .SRCINFO
  $ git -C "$REPO" commit -qm initial
  $ printf 'touch %q\npkgver=2.0\npkgrel=1\n' "$MARKER" > "$REPO/PKGBUILD"
  $ printf 'pkgbase = demo\n\tpkgver = 2.0\n\tpkgrel = 1\n' > "$REPO/.SRCINFO"
  $ git -C "$REPO" add PKGBUILD .SRCINFO
  $ git -C "$REPO" commit -qm malicious
  $ cd "$REPO"
  $ git log --format=%H | while IFS= read -r hash; do get_commit_version "$hash"; done
  2.0-1
  1.0-1
  $ test ! -e "$MARKER"

Commits without .SRCINFO have an unknown version:
  $ rm .SRCINFO
  $ git add .SRCINFO
  $ git commit -qm no-srcinfo
  $ get_commit_version HEAD
  ?

Cleanup:
  $ cd /
  $ rm -rf "$REPO" /tmp/aurpick-srcinfo-pwned
