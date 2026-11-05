# Engineering

Public, downloadable reverse-engineering toolkit. Clone or grab a release zip/tarball and run it on your machine.

Analysis itself is read-only (no transactions, no private keys). Contract scripts only call `eth_getCode` / `eth_getStorageAt`.

## Download

- **Clone:** `git clone https://github.com/mcontwitter-glitch/Engineering.git`
- **Release:** see [Releases](https://github.com/mcontwitter-glitch/Engineering/releases) for a ready archive

## What you need installed locally

- JDK 25+ (Ghidra 12.2 needs Java 25)
- [Ghidra](https://github.com/NationalSecurityAgency/ghidra/releases) 12.2 at `/opt/ghidra/current` (or edit the scripts)
- [Heimdall](https://github.com/Jon-Becker/heimdall-rs/releases) at `/usr/local/bin/heimdall`
- `pycryptodome` for `compare-source.py` (`pip install pycryptodome`)

## Usage

```bash
./re-binary.sh <file> [outdir]            # Ghidra: decompiled.c, functions.txt, imports.txt, strings.txt
./re-contract.sh <address> <rpc> [outdir] # bytecode, asm, decompiled.sol, abi, selectors
                                          # EIP-1967 proxy → also analyzes implementation/
./compare-source.py <outdir> <Source.sol> # map selectors back to source names
```

Default output directory: `./re-out/<name>-<timestamp>/` (override with the optional outdir arg).

## Example RPCs

- Abstract (2741): `https://api.mainnet.abs.xyz`
- Ethereum (1): `https://eth.llamarpc.com`
- Base (8453): `https://mainnet.base.org`
- BNB (56): `https://bsc-dataseed.binance.org`
- ApeChain (33139): `https://rpc.apechain.com/http`
- Robinhood: `https://rpc.mainnet.chain.robinhood.com`

## Limitations

- Heimdall resolves names only for known signatures; custom functions show as `Unresolved_<selector>`.
- `compare-source.py` does not expand struct params into tuples.
- Only follows the EIP-1967 implementation slot (not beacon proxies, diamonds, or EIP-1167 clones).
