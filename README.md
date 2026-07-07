# aurpick

[中文文档](README.zh.md) | English

---

Easily install a specific version of AUR packages — current, historical, or newer.

**aurpick** lets you browse complete Git history, preview PKGBUILDs, and pick the exact version you need.

## Features

- **Complete History Browsing** - View all Git commit history of the package
- **Interactive Selection** - Powerful search and filtering via fzf
- **Version Information** - Automatically parse PKGBUILD version from each commit
- **Live Preview** - View commit information and PKGBUILD content
- **Official Package Redirect** - Auto-detect official repo packages and invoke `downgrade`
- **GitHub Mirror Support** - Optional GitHub AUR mirror to reduce load on official AUR and avoid service disruptions
- **Wayback Fallback** - Try archived source files when upstream URLs are gone, while still honoring `makepkg` integrity checks
- **No AUR Helper Required** - Works independently using only git and makepkg
- **Development Mode** - Preserve temporary files for debugging

## Dependencies

- `git` - Clone AUR repositories
- `curl` - Probe source URLs and query Wayback Machine
- `fzf` - Interactive selection interface
- `base-devel` - Build AUR packages (includes `makepkg`)
- `downgrade` (optional) - Handle official repository packages

Install dependencies:
```bash
sudo pacman -S git curl fzf base-devel
```

## Usage

**Basic usage**:
```bash
aurpick <package-name>
```

**Examples**:
```bash
# Rollback yay after a problematic update
aurpick yay

# Use GitHub AUR mirror (read-only experimental mirror)
aurpick --github yay

# Development mode (preserve temporary files for debugging)
aurpick --dev yay

# Disable archived-source fallback and use only live upstream URLs
aurpick --no-wayback yay
```

## ⚠️ Important Limitations

**Using aurpick is pointless or will fail for at least the following types of packages:**

1. **VCS packages** (`-git`, `-svn`, `-hg`, etc.)
   - These packages use `pkgver()` functions to dynamically fetch the latest upstream source code during build time
   - Even if you select a historical PKGBUILD, it will still build the current upstream version

2. **Packages with version-agnostic download URLs**
   - Source URLs like `https://example.com/latest.tar.xz` always point to the newest file
   - Selecting historical PKGBUILDs won't fetch the corresponding historical source files

3. **Packages with deleted upstream sources**
   - aurpick can try the Wayback Machine when a live HTTP(S) source disappears
   - By default, recovery still fails if there is no archived copy or the archived file does not pass `makepkg` verification

## How It Works

1. Clone the AUR Git repository for the specified package (from official AUR or GitHub mirror)
2. Traverse all commit history and extract PKGBUILD version information
3. Provide interactive selection interface via fzf
4. Switch to the selected historical commit
5. Verify sources with `makepkg`, optionally trying Wayback for missing HTTP(S) files
6. Build and install using `makepkg`

## Options

- `--dev` - Development mode, preserve temporary files in `/tmp/aurpick-<package>`
- `--github` - Use GitHub AUR mirror instead of official AUR source
- `--no-wayback` - Disable Wayback fallback and rely only on live upstream source URLs
- `--version` / `-v` - Show version information

## Usage Tips

- This tool focuses on **AUR packages**. Official repository packages will be redirected to the `downgrade` tool if available
- Older versions may encounter checksum mismatches. You can skip verification if needed
- Wayback fallback only applies to unreachable `http://` and `https://` sources; VCS sources such as `git+...` are unchanged
- Archived files go through normal `makepkg` integrity checks unless you explicitly choose `--skipchecksums` after a verification failure

## Development

### Development Dependencies

For testing and development:
```bash
sudo pacman -S shellcheck python-cram
```

- `shellcheck` - Static analysis for shell scripts
- `python-cram` - Command-line testing framework

### Running Tests

Run the complete test suite:
```bash
bash test.sh
```

This will:
1. Run `shellcheck` for static code analysis
2. Run all `cram` functional tests

Please ensure all tests pass before submitting code.

### Project Structure

```
aurpick/
├── aurpick          # Main executable script
├── test.sh          # Test runner (shellcheck + cram)
├── test/            # Test cases (cram format)
│   ├── basic.t
│   ├── version.t
│   ├── dev-mode.t
│   └── ...
├── README.md        # Documentation (English)
└── README.zh.md     # Documentation (Chinese)
```

## License

MIT License - See [LICENSE](LICENSE)
