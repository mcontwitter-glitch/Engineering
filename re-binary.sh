#!/usr/bin/env bash
# Read-only binary RE via Ghidra headless. Usage: re-binary.sh <file> [outdir]
set -euo pipefail
f=$(readlink -f "$1"); name=$(basename "$f")
out=${2:-/workspace/re-out/$name-$(date +%Y%m%d-%H%M%S)}; mkdir -p "$out"; out=$(readlink -f "$out")
export JAVA_HOME=/opt/jdk/current MAXMEM=${MAXMEM:-2G}
here=$(dirname "$(readlink -f "$0")"); proj=$(mktemp -d)
/opt/ghidra/current/support/analyzeHeadless "$proj" re -import "$f" -scriptPath "$here" \
  -postScript ExportDecomp.java "$out" -deleteProject >"$out/ghidra.log" 2>&1 || { tail -20 "$out/ghidra.log"; exit 1; }
rm -rf "$proj"
command -v strings >/dev/null && strings -n 6 "$f" > "$out/strings-raw.txt" || true
echo "Output: $out"; wc -l "$out"/functions.txt "$out"/imports.txt "$out"/strings.txt
