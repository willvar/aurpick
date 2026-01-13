#!/bin/bash
# Simple test runner for aurpick

set -e

# Check if shellcheck is installed
if ! command -v shellcheck &>/dev/null; then
    echo "Warning: shellcheck is not installed"
    echo "Install with: sudo pacman -S shellcheck"
    echo "Skipping shellcheck validation..."
    echo ""
else
    echo "Running shellcheck..."
    if shellcheck --exclude=SC1090,SC2154 aurpick; then
        echo "✓ shellcheck passed"
        echo ""
    else
        echo "✗ shellcheck failed"
        exit 1
    fi
fi

# Check if cram is installed
if ! command -v cram &>/dev/null; then
    echo "Error: cram is not installed"
    echo "Install with: sudo pacman -S python-cram"
    exit 1
fi

echo "Running cram tests..."
cram test/*.t

echo ""
echo "All tests passed!"
