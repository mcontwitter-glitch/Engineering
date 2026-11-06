#!/usr/bin/env bash
# Read-only EVM contract RE. Usage: re-contract.sh <address> <rpc-url> [outdir]
set -euo pipefail
addr=$1; rpc=$2
out=${3:-./re-out/$addr-$(date +%Y%m%d-%H%M%S)}; mkdir -p "$out"
rpccall(){ # $1 json body → prints result or fails with HTTP status
  local body=$1 tmp code
  tmp=$(mktemp)
  code=$(curl -sS -o "$tmp" -w '%{http_code}' -X POST -H 'content-type: application/json' --data "$body" "$rpc" || echo curl_fail)
  if [[ "$code" != "200" ]]; then
    echo "RPC HTTP $code from $rpc" >&2
    head -c 400 "$tmp" >&2; echo >&2
    if [[ "$code" == "402" ]]; then
      echo "402 Payment Required means this RPC wants payment (x402 / paid provider)." >&2
      echo "Use a free public RPC instead, e.g. https://ethereum.publicnode.com" >&2
    fi
    rm -f "$tmp"; return 1
  fi
  python3 -c 'import sys,json;d=json.load(open(sys.argv[1]));
e=d.get("error");
sys.exit("RPC error: "+str(e)) if e else print(d.get("result",""))' "$tmp"
  rm -f "$tmp"
}
analyze(){ # $1 addr  $2 dir
  local a=$1 d=$2; mkdir -p "$d"
  local code; code=$(rpccall "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"eth_getCode\",\"params\":[\"$a\",\"latest\"]}")
  echo "$code" > "$d/bytecode.hex"
  [ ${#code} -le 4 ] && { echo "No code at $a"; return 1; }
  echo "[$a] $(( (${#code}-2)/2 )) bytes"
  heimdall disassemble "$code" -o "$d" >"$d/heimdall-disasm.log" 2>&1 || echo "  disassemble failed (see log)"
  heimdall decompile "$code" --include-sol -o "$d" >"$d/heimdall-decompile.log" 2>&1 || echo "  decompile failed (see log)"
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
