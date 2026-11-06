#!/usr/bin/env bash
# Read-only binary RE via Ghidra headless. Usage: re-binary.sh <file> [outdir]
set -euo pipefail
f=$(readlink -f "$1"); name=$(basename "$f")
out=${2:-./re-out/$name-$(date +%Y%m%d-%H%M%S)}; mkdir -p "$out"; out=$(readlink -f "$out")
JAVA_HOME=${JAVA_HOME:-/opt/jdk/current}
GHIDRA_HOME=${GHIDRA_HOME:-/opt/ghidra/current}
export JAVA_HOME MAXMEM=${MAXMEM:-2G}
PATH="$JAVA_HOME/bin:$PATH"
here=$(dirname "$(readlink -f "$0")"); proj=$(mktemp -d)
"$GHIDRA_HOME/support/analyzeHeadless" "$proj" re -import "$f" -scriptPath "$here" \
  -postScript ExportDecomp.java "$out" -deleteProject >"$out/ghidra.log" 2>&1 || { tail -20 "$out/ghidra.log"; exit 1; }
rm -rf "$proj"
command -v strings >/dev/null && strings -n 6 "$f" > "$out/strings-raw.txt" || true
echo "Output: $out"; wc -l "$out"/functions.txt "$out"/imports.txt "$out"/strings.txt
