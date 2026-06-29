# 🏗️ ETH on Rails

An open-source toolkit for building decentralized applications on Ethereum — a
[Scaffold-ETH 2](https://github.com/scaffold-eth/scaffold-eth-2) port to **Ruby on
Rails**. It keeps Scaffold-ETH's developer experience (auto-generated contract UI,
typed reads/writes, debug page, block explorer, faucet, burner wallet) while
replacing the Next.js frontend with a **Rails 8 + Hotwire** app and using
[`eth.rb`](https://github.com/q9f/eth.rb) as the server-side Ethereum library.

## How it maps to Scaffold-ETH 2

| Scaffold-ETH 2 | ETH on Rails |
| --- | --- |
| Next.js app (`packages/nextjs`) | Rails 8 app (`packages/rails`) |
| viem (reads/encoding) | **viem** in-browser **+ `eth.rb`** on the server |
| wagmi hooks | `@wagmi/core` actions wrapped in **Stimulus controllers** |
| RainbowKit | **Reown AppKit** (`<appkit-button>`) |
| React components (Address, Balance, …) | **ViewComponents** + Stimulus |
| `deployedContracts.ts` (hot reload) | `config/contracts/deployed_contracts.json` (mtime hot reload) |
| TailwindCSS + DaisyUI | TailwindCSS v4 + DaisyUI (same themes) |
| Hardhat **or** Foundry | **both** `packages/hardhat` and `packages/foundry` |

Because browser wallet connection and user-signed transactions are inherently
JavaScript, ETH on Rails is two-layered:

- **Client (faithful to SE-2):** `viem` + `@wagmi/core` + `@reown/appkit`, bundled
  with esbuild and driven by Stimulus controllers that mirror the SE-2 hooks
  1:1 (`scaffold-read-contract`, `scaffold-write-contract`, `scaffold-watch-event`,
  `scaffold-event-history`, `transactor`, …). **All writes are signed in the browser.**
- **Server (`eth.rb`):** the contract registry, server-side reads, the faucet, the
  block explorer + event decoding, and ENS — exposed via a small JSON API
  (`/api/*`). Writes are deliberately **not** exposed server-side.

## Requirements

- **Ruby** ≥ 3.2 and Bundler
- **Node** ≥ 20 and **Yarn** (classic)
- A local chain: **Foundry** (`anvil`) and/or **Hardhat** (installed via the workspace)

## Quick start

```bash
# 1. Install JS workspace deps (hardhat + foundry packages) and Rails gems/npm
yarn install
cd packages/rails && bundle install && yarn install && bin/rails db:prepare && cd ../..

# 2. Start a local chain (pick one)
yarn chain            # Hardhat node            (terminal 1)
# or
yarn foundry:chain    # anvil

# 3. Deploy the sample contract -> regenerates config/contracts/deployed_contracts.json
yarn deploy           # Hardhat   (terminal 2)
# or
yarn foundry:deploy   # Foundry

# 4. Run the Rails app + asset watchers
cd packages/rails && bin/dev      # (terminal 3) -> http://localhost:3000
```

Open <http://localhost:3000>, click **🔥 Burner** to connect a throwaway local
account, hit **💧** to fund it from the faucet, then visit **Debug Contracts** to
read/write `YourContract` and **Block Explorer** to inspect your transactions.

## Repo layout

```
packages/
├── hardhat/   # Solidity + Hardhat: YourContract.sol, deploy/verify, JSON ABI generator
├── foundry/   # Solidity + Foundry: same contract + forge scripts + JSON ABI generator
└── rails/     # the Rails 8 dapp (replaces packages/nextjs)
    ├── app/services/scaffold_eth/   # eth.rb layer: Config, Client, ContractRegistry,
    │                                #   Reader, Events, Ens, Faucet, BlockExplorer
    ├── app/components/scaffold_eth/  # web3 ViewComponents (Address, Balance, inputs, …)
    ├── app/javascript/lib/           # wagmi/viem + AppKit + burner setup
    ├── app/javascript/controllers/   # Stimulus controllers mirroring SE-2 hooks
    ├── app/controllers/api/          # JSON API backed by eth.rb
    └── config/
        ├── scaffold_eth.yml          # the scaffold.config.ts analogue
        ├── scaffold_eth/chains.yml   # chain metadata (viem chains analogue)
        └── contracts/                # generated + external contract artifacts
```

## Configuration

Edit `packages/rails/config/scaffold_eth.yml` to choose target networks, polling
interval, the WalletConnect/Reown project id, the Alchemy key, and the burner-wallet
policy. Add chains in `config/scaffold_eth/chains.yml`. See `.env.example` for the
environment variables.

## Contract workflow

`yarn deploy` (Hardhat) or `yarn foundry:deploy` (Foundry) compiles, deploys, and
regenerates `packages/rails/config/contracts/deployed_contracts.json`. The running
Rails app re-reads that file on change (mtime cache-bust) — **no restart needed** —
and the esbuild watcher rebuilds the JS bundle, so a page refresh picks up the new
ABI/address. Add contracts you didn't deploy (e.g. mainnet DAI) to
`config/contracts/external_contracts.json`.

Other scripts: `yarn account` / `yarn account:generate` / `yarn account:import`,
`yarn chain` / `yarn fork`, `yarn verify` (and the `yarn foundry:*` equivalents).

## Deployment

The Rails app ships a Kamal config (`config/deploy.yml`) and Dockerfile (Rails 8
defaults). Set production target networks in `scaffold_eth.yml` and provide
`ALCHEMY_API_KEY` + `WALLET_CONNECT_PROJECT_ID`. Deploy contracts to a live network
with `yarn deploy --network sepolia` (Hardhat) or `RPC_URL=sepolia yarn foundry:deploy`.

## License

MIT.
