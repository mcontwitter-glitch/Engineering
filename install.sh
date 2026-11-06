#!/usr/bin/env bash
# Full Engineering toolkit install: JDK 25 + Ghidra 12.2 + Heimdall + Python dep.
# Usage: ./install.sh [--user]
#   default: install engines under /opt and heimdall to /usr/local/bin (may need sudo)
#   --user:  install under ~/.local/opt and ~/.local/bin (no sudo)
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
USER_MODE=0
for a in "$@"; do case "$a" in --user) USER_MODE=1 ;; -h|--help) sed -n '2,6p' "$0"; exit 0 ;; esac; done

if [[ $USER_MODE -eq 1 ]]; then
  export PREFIX_JDK="$HOME/.local/opt/jdk"
  export PREFIX_GHIDRA="$HOME/.local/opt/ghidra"
  export BINDIR="$HOME/.local/bin"
  mkdir -p "$BINDIR"
  echo "User install → $HOME/.local"
else
  export PREFIX_JDK=/opt/jdk
  export PREFIX_GHIDRA=/opt/ghidra
  export BINDIR=/usr/local/bin
  echo "System install → /opt and /usr/local/bin (sudo may prompt)"
fi

# unzip needed for Ghidra
if ! command -v unzip >/dev/null; then
  echo "unzip is required. On Debian/Ubuntu: sudo apt-get install -y unzip"
  exit 1
fi
if ! command -v curl >/dev/null; then
  echo "curl is required."; exit 1
fi

"$HERE/install-jdk.sh" "$PREFIX_JDK"
"$HERE/install-ghidra.sh" "$PREFIX_GHIDRA"
"$HERE/install-heimdall.sh" "$BINDIR"

# Python helper
python3 -m pip install --user -q pycryptodome 2>/dev/null || pip3 install --user -q pycryptodome || true

# Convenience: write env file
ENVF="$HERE/env.sh"
cat > "$ENVF" << ENV
export JAVA_HOME="$PREFIX_JDK/current"
export PATH="\$JAVA_HOME/bin:$BINDIR:\$PATH"
export GHIDRA_HOME="$PREFIX_GHIDRA/current"
ENV
chmod +x "$HERE"/re-binary.sh "$HERE"/re-contract.sh "$HERE"/compare-source.py \
  "$HERE"/install.sh "$HERE"/install-jdk.sh "$HERE"/install-ghidra.sh "$HERE"/install-heimdall.sh

echo
echo "Install complete."
echo "  source $ENVF"
echo "  ./re-binary.sh /path/to/binary"
echo "  ./re-contract.sh 0xAddress https://ethereum.publicnode.com"
