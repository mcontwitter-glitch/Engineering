# Engineering

Public, downloadable reverse-engineering toolkit. Clone or grab a [release](https://github.com/mcontwitter-glitch/Engineering/releases), run the installers, then decompile binaries and contracts on your machine.

Analysis itself is read-only (no transactions, no private keys). Contract scripts only call `eth_getCode` / `eth_getStorageAt`.

## MC install guide

Step-by-step install instructions live in [`MC install guide.md`](./MC%20install%20guide.md).

## Quick start

```bash
git clone https://github.com/mcontwitter-glitch/Engineering.git
cd Engineering
./install.sh          # JDK 25 + Ghidra 12.2 + Heimdall (may need sudo)
# or: ./install.sh --user   # installs under ~/.local, no sudo
source ./env.sh       # written by install.sh
./re-binary.sh /bin/ls
./re-contract.sh 0xAddress https://ethereum.publicnode.com
```

## Install scripts (download the engines)

| Script | What it installs |
|---|---|
| `install.sh` | Full setup (JDK + Ghidra + Heimdall + pycryptodome) |
| `install-jdk.sh` | Temurin JDK 25 → `/opt/jdk` (or `PREFIX=...`) |
| `install-ghidra.sh` | Official Ghidra 12.2 PUBLIC → `/opt/ghidra` |
| `install-heimdall.sh` | Heimdall 0.9.3 binary → `/usr/local/bin` |

These scripts pull the official release archives from GitHub / Adoptium. The heavy engines are **not** stored in this repo (Ghidra alone is ~540MB).

## Usage

```bash
./re-binary.sh <file> [outdir]            # Ghidra: decompiled.c, functions.txt, imports.txt, strings.txt
./re-contract.sh <address> <rpc> [outdir] # bytecode, asm, decompiled.sol, abi, selectors
./compare-source.py <outdir> <Source.sol> # map selectors back to source names
```

Default output: `./re-out/<name>-<timestamp>/`

## Example RPCs

- Abstract (2741): `https://api.mainnet.abs.xyz`
- Ethereum (1): `https://ethereum.publicnode.com`
- Base (8453): `https://mainnet.base.org`
- BNB (56): `https://bsc-dataseed.binance.org`
- ApeChain (33139): `https://rpc.apechain.com/http`
- Robinhood: `https://rpc.mainnet.chain.robinhood.com`

## Limitations

- Heimdall resolves names only for known signatures; custom functions show as `Unresolved_<selector>`.
- `compare-source.py` does not expand struct params into tuples.
- Only follows the EIP-1967 implementation slot (not beacon proxies, diamonds, or EIP-1167 clones).
- Ghidra EVM plugin is not included (current public plugins do not support Ghidra 12.2).
