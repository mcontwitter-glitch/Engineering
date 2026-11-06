# MC install guide

How to download and install the Engineering reverse-engineering toolkit so the run engines actually work on your machine.

## 1. Get the files

Pick one:

- **Clone:** `git clone https://github.com/mcontwitter-glitch/Engineering.git && cd Engineering`
- **Release archive:** open [Releases](https://github.com/mcontwitter-glitch/Engineering/releases), download the latest `.tar.gz`, then:
  ```bash
  tar -xzf Engineering-*.tar.gz
  cd Engineering-*
  ```

## 2. Install the engines

The repo is wrappers + this guide. Ghidra, JDK, and Heimdall are downloaded by the install scripts.

**System install** (needs `sudo`, puts engines in `/opt` and `/usr/local/bin`):

```bash
./install.sh
source ./env.sh
```

**User install** (no sudo, puts engines under `~/.local`):

```bash
./install.sh --user
source ./env.sh
```

You need `curl` and `unzip` already installed. On Debian/Ubuntu:

```bash
sudo apt-get update && sudo apt-get install -y curl unzip
```

What `install.sh` runs for you:

1. `install-jdk.sh` — Temurin JDK 25 (Ghidra 12.2 needs Java 25)
2. `install-ghidra.sh` — official Ghidra 12.2 PUBLIC (~540MB)
3. `install-heimdall.sh` — Heimdall 0.9.3
4. `pycryptodome` via pip (for `compare-source.py`)

You can also run any of those three scripts alone if you only need one piece.

## 3. Check the install

```bash
source ./env.sh
java -version          # should show 25.x
heimdall --version     # should show 0.9.x
ls "$GHIDRA_HOME"      # Ghidra tree
```

## 4. Run it

**Binary (Ghidra):**

```bash
./re-binary.sh /path/to/program
# output under ./re-out/<name>-<timestamp>/
```

**Contract (Heimdall, read-only RPC):**

```bash
./re-contract.sh 0xYourContract https://eth.llamarpc.com
```

**Match decompiled selectors to Solidity source:**

```bash
./compare-source.py ./re-out/<that-outdir> ./YourContract.sol
```

## 5. Notes

- Analysis is read-only: no transactions, no private keys.
- Nothing in this repo stores your keys.
- Ghidra alone is large; first install takes a few minutes depending on your network.
- Default paths after a system install: `/opt/jdk/current`, `/opt/ghidra/current`, `/usr/local/bin/heimdall`.
- After every new shell, run `source ./env.sh` (or add those exports to your shell profile).

## Example RPCs

| Chain | RPC |
|---|---|
| Ethereum | `https://eth.llamarpc.com` |
| Base | `https://mainnet.base.org` |
| BNB | `https://bsc-dataseed.binance.org` |
| Abstract | `https://api.mainnet.abs.xyz` |
| ApeChain | `https://rpc.apechain.com/http` |
| Robinhood | `https://rpc.mainnet.chain.robinhood.com` |

Repo: https://github.com/mcontwitter-glitch/Engineering
