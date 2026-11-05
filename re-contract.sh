#!/usr/bin/env bash
# Read-only EVM contract RE. Usage: re-contract.sh <address> <rpc-url> [outdir]
set -euo pipefail
addr=$1; rpc=$2
out=${3:-/workspace/re-out/$addr-$(date +%Y%m%d-%H%M%S)}; mkdir -p "$out"
rpccall(){ curl -s -X POST -H 'content-type: application/json' --data "$1" "$rpc" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("result",""))'; }
analyze(){ # $1 addr  $2 dir
  local a=$1 d=$2; mkdir -p "$d"
  local code; code=$(rpccall "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"eth_getCode\",\"params\":[\"$a\",\"latest\"]}")
  echo "$code" > "$d/bytecode.hex"
  [ ${#code} -le 4 ] && { echo "No code at $a"; return 1; }
  echo "[$a] $(( (${#code}-2)/2 )) bytes"
  heimdall disassemble "$code" -o "$d" >"$d/heimdall-disasm.log" 2>&1 || echo "  disassemble failed (see log)"
  heimdall decompile "$code" --include-sol -o "$d" >"$d/heimdall-decompile.log" 2>&1 || echo "  decompile failed (see log)"
  # selectors: PUSH4 values from disassembly (best effort)
  grep -hoE 'PUSH4 (0x)?[0-9a-f]{8}' "$d"/*.asm 2>/dev/null | awk '{sub(/^0x/,"",$2);print $2}' | sort -u > "$d/selectors.txt" || true
  echo "  files: $(ls "$d" | tr '\n' ' ')"
}
analyze "$addr" "$out"
slot=0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
impl=$(rpccall "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"eth_getStorageAt\",\"params\":[\"$addr\",\"$slot\",\"latest\"]}")
if [ -n "$impl" ] && [ "$(echo "$impl" | tr -d '0x')" != "" ]; then
  impl=0x${impl: -40}; echo "EIP-1967 proxy -> implementation $impl" | tee "$out/proxy.txt"
  analyze "$impl" "$out/implementation"
fi
echo "Output: $out"
