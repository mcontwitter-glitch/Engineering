#!/usr/bin/env bash
# Install official Ghidra 12.2 PUBLIC. Usage: ./install-ghidra.sh [prefix]
# Default prefix: /opt/ghidra. Requires JDK 25 (run install-jdk.sh first).
set -euo pipefail
PREFIX=${1:-${PREFIX:-/opt/ghidra}}
TAG=${GHIDRA_TAG:-Ghidra_12.2_build}
ZIP=${GHIDRA_ZIP:-ghidra_12.2_PUBLIC_20261016.zip}
url="https://github.com/NationalSecurityAgency/ghidra/releases/download/${TAG}/${ZIP}"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "Downloading $ZIP (~540MB)..."
curl -fsSL -o "$tmp/ghidra.zip" -L "$url"
mkdir -p "$tmp/extract"
unzip -q "$tmp/ghidra.zip" -d "$tmp/extract"
inner=$(find "$tmp/extract" -maxdepth 1 -mindepth 1 -type d | head -1)
need_sudo=0
if [[ "$PREFIX" == /opt/* ]] || [[ ! -w "$(dirname "$PREFIX")" ]]; then need_sudo=1; fi
SUDO=(); if [[ $need_sudo -eq 1 ]] && [[ ${EUID:-$(id -u)} -ne 0 ]]; then SUDO=(sudo); fi
"${SUDO[@]}" mkdir -p "$PREFIX"
name=$(basename "$inner")
"${SUDO[@]}" rm -rf "$PREFIX/$name"
"${SUDO[@]}" mv "$inner" "$PREFIX/$name"
"${SUDO[@]}" ln -sfn "$PREFIX/$name" "$PREFIX/current"
# Headless default heap
if [[ -f "$PREFIX/current/support/analyzeHeadless" ]]; then
  "${SUDO[@]}" sed -i.bak 's/^MAXMEM=.*/MAXMEM=2G/' "$PREFIX/current/support/analyzeHeadless" 2>/dev/null || true
fi
echo "Ghidra installed at $PREFIX/current -> $PREFIX/$name"
echo "Set JAVA_HOME to your JDK 25 before running analyzeHeadless."
