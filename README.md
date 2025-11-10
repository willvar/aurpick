# aurpick

[中文文档](README.zh.md) | English

---

Easily install any version of AUR packages — current, historical, or newer.

**aurpick** lets you browse complete Git history, preview PKGBUILDs, and pick the exact version you need.

## Features

- **Complete History Browsing** - View all Git commit history of the package
- **Interactive Selection** - Powerful search and filtering via fzf
- **Version Information** - Automatically parse PKGBUILD version from each commit
- **Live Preview** - View commit information and PKGBUILD content
- **Official Package Redirect** - Auto-detect official repo packages and invoke `downgrade`
- **GitHub Mirror Support** - Optional GitHub AUR mirror for package fetching
- **Development Mode** - Preserve temporary files for debugging

## Dependencies

- `git` - Clone AUR repositories
- `fzf` - Interactive selection interface
- `base-devel` - Build AUR packages (includes `makepkg`)
- `downgrade` (optional) - Handle official repository packages

Install dependencies:
```bash
sudo pacman -S git fzf base-devel
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
```

## How It Works

1. Clone the AUR Git repository for the specified package (from official AUR or GitHub mirror)
2. Traverse all commit history and extract PKGBUILD version information
3. Provide interactive selection interface via fzf
4. Switch to the selected historical commit
5. Build and install using `makepkg`

## Options

- `--dev` - Development mode, preserve temporary files in `/tmp/aurpick-<package>`
- `--github` - Use GitHub AUR mirror instead of official AUR source
- `--version` / `-v` - Show version information

## Usage Tips

- This tool focuses on **AUR packages**. Official repository packages are automatically redirected to the `downgrade` tool
- Older versions may have checksum mismatches due to changed upstream sources. You can skip verification if needed

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
