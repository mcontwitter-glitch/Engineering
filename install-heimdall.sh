#!/usr/bin/env bash
# Install Heimdall EVM decompiler. Usage: ./install-heimdall.sh [bindir]
# Default bindir: /usr/local/bin
set -euo pipefail
BINDIR=${1:-${BINDIR:-/usr/local/bin}}
VER=${HEIMDALL_VERSION:-0.9.3}
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$OS" in linux) plat=linux ;; darwin) plat=macos ;; *) echo "Unsupported OS: $OS"; exit 1 ;; esac
case "$ARCH" in x86_64|amd64) a=amd64 ;; aarch64|arm64) a=arm64 ;; *) echo "Unsupported arch: $ARCH"; exit 1 ;; esac
asset="heimdall-${plat}-${a}"
url="https://github.com/Jon-Becker/heimdall-rs/releases/download/${VER}/${asset}"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "Downloading $asset ($VER)..."
curl -fsSL -o "$tmp/heimdall" -L "$url"
chmod +x "$tmp/heimdall"
need_sudo=0
if [[ ! -w "$BINDIR" ]]; then need_sudo=1; fi
SUDO=(); if [[ $need_sudo -eq 1 ]] && [[ ${EUID:-$(id -u)} -ne 0 ]]; then SUDO=(sudo); fi
"${SUDO[@]}" mkdir -p "$BINDIR"
"${SUDO[@]}" mv "$tmp/heimdall" "$BINDIR/heimdall"
echo "Heimdall installed at $BINDIR/heimdall"
"$BINDIR/heimdall" --version
