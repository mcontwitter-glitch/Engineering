# re-toolkit (read-only reverse engineering)

No transactions, no keys. Contract scripts only make eth_getCode / eth_getStorageAt RPC reads.

## Installed
- JDK 25 (Temurin 25.0.5): /opt/jdk/current  (Ghidra 12.2 requires Java 25; apt was unavailable)
- Ghidra 12.2 (ghidra_12.2_PUBLIC_20261016): /opt/ghidra/current, analyzeHeadless MAXMEM_DEFAULT=2G
- Heimdall 0.9.2 (release 0.9.3 binary): /usr/local/bin/heimdall
- pycryptodome (user pip) for compare-source.py
- Ghidra EVM plugin: not installed (Mothra/ghidra-evm don't support Ghidra 12.2)

## Usage
    ./re-binary.sh <file> [outdir]           # Ghidra: decompiled.c, functions.txt, imports.txt, strings.txt, strings-raw.txt
    ./re-contract.sh <address> <rpc> [outdir] # bytecode.hex, disassembled.asm, decompiled.sol, abi.json, selectors.txt
                                              # EIP-1967 proxy → also analyzes implementation/ subdir
    ./compare-source.py <outdir> <Source.sol> # check source selectors against the bytecode
Default output: /workspace/re-out/<name>-<timestamp>/

## RPCs (from /workspace/BRIDGE)
- Abstract (2741):    https://api.mainnet.abs.xyz
- Ethereum (1):       https://eth.llamarpc.com  (alt https://ethereum.reth.rs/rpc)
- Base (8453):        https://mainnet.base.org
- BNB (56):           https://bsc-dataseed.binance.org
- ApeChain (33139):   https://rpc.apechain.com/http
- Robinhood chain:    https://rpc.mainnet.chain.robinhood.com

## Limitations
- Heimdall resolves names only for known signatures; custom functions show as Unresolved_<selector>.
  compare-source.py maps them back when you have the source.
- compare-source.py doesn't expand struct params into tuples, so functions that take structs show NO.
- Only checks the EIP-1967 implementation slot. Beacon proxies, diamonds and EIP-1167 clones aren't followed.
