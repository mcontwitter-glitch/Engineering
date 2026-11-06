#!/usr/bin/env bash
# Install Temurin JDK 25 (required by Ghidra 12.2). Usage: ./install-jdk.sh [prefix]
# Default prefix: /opt/jdk (needs sudo) or set PREFIX=~/.local/opt/jdk
set -euo pipefail
PREFIX=${1:-${PREFIX:-/opt/jdk}}
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in x86_64|amd64) A=x64 ;; aarch64|arm64) A=aarch64 ;; *) echo "Unsupported arch: $ARCH"; exit 1 ;; esac
case "$OS" in linux) O=linux ;; darwin) O=mac ;; *) echo "Unsupported OS: $OS"; exit 1 ;; esac

url="https://api.adoptium.net/v3/binary/latest/25/ga/${O}/${A}/jdk/hotspot/normal/eclipse?project=jdk"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "Downloading Temurin JDK 25 for ${O}/${A}..."
curl -fsSL -o "$tmp/jdk.tgz" -L "$url"
mkdir -p "$tmp/extract"
tar -xzf "$tmp/jdk.tgz" -C "$tmp/extract"
inner=$(find "$tmp/extract" -maxdepth 1 -mindepth 1 -type d | head -1)
need_sudo=0
if [[ "$PREFIX" == /opt/* ]] || [[ ! -w "$(dirname "$PREFIX")" ]]; then need_sudo=1; fi
SUDO=(); if [[ $need_sudo -eq 1 ]] && [[ ${EUID:-$(id -u)} -ne 0 ]]; then SUDO=(sudo); fi
"${SUDO[@]}" mkdir -p "$PREFIX"
name=$(basename "$inner")
"${SUDO[@]}" rm -rf "$PREFIX/$name"
"${SUDO[@]}" mv "$inner" "$PREFIX/$name"
"${SUDO[@]}" ln -sfn "$PREFIX/$name" "$PREFIX/current"
echo "JDK installed at $PREFIX/current -> $PREFIX/$name"
"$PREFIX/current/bin/java" -version
