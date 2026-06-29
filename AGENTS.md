# AGENTS.md — working in ETH on Rails

This repo is a Scaffold-ETH 2 port to Ruby on Rails. Read this before making changes.

## Architecture (two layers, on purpose)

- **Server (Ruby / `eth.rb`)** — `packages/rails/app/services/scaffold_eth/`:
  - `Config` loads `config/scaffold_eth.yml`; `Chains` loads `config/scaffold_eth/chains.yml`.
  - `Client` wraps `Eth::Client`; `ContractRegistry` builds `Eth::Contract` from the
    JSON artifacts; `Reader` does server reads; `Events` decodes logs; `Ens`,
    `Faucet`, `BlockExplorer` round it out.
  - Exposed to the browser via `app/controllers/api/*` (`/api/config`, `/api/contracts`,
    `/api/read`, `/api/events`, `/api/ens`, `/api/faucet`, `/api/blocks`).
  - **Reads can be server-side; writes are never server-side.**
- **Client (JS)** — `packages/rails/app/javascript/`:
  - `lib/wagmi.js` sets up `@wagmi/core` + `@reown/appkit` (created from
    `ScaffoldEth::Config#to_browser_json`, injected via a `<meta>` tag).
  - `lib/burner.js` is the burner-wallet wagmi connector (viem local account).
  - `controllers/*` are Stimulus controllers mirroring the SE-2 hooks 1:1.

## Conventions

- **Adding a contract:** write the Solidity in `packages/hardhat/contracts` and/or
  `packages/foundry/contracts`, add a deploy step, then `yarn deploy` /
  `yarn foundry:deploy`. The JSON artifact regenerates automatically; don't hand-edit
  `config/contracts/deployed_contracts.json` (it's generated). Use
  `external_contracts.json` for contracts you didn't deploy.
- **New web3 UI:** add a `ViewComponent` under `app/components/scaffold_eth/` plus a
  Stimulus controller; register the controller in
  `app/javascript/controllers/index.js`.
- **New hook-like behavior:** add a `scaffold-*` Stimulus controller that imports
  `wagmiConfig` from `lib/wagmi` and uses `@wagmi/core` actions. Keep the name aligned
  with the SE-2 hook it mirrors.
- **Reads vs writes:** server reads go through `ScaffoldEth::Reader` / `/api/read`;
  writes go through the `scaffold-write-contract` controller (browser-signed via viem).
  Never add a server endpoint that signs transactions.
- **Styling:** TailwindCSS v4 + DaisyUI; themes `scaffoldEth` / `scaffoldEthDark` in
  `app/assets/stylesheets/application.tailwind.css`.

## Build & run

- `bin/dev` runs the Rails server + `yarn build --watch` (esbuild, via
  `esbuild.config.mjs`) + `yarn build:css --watch`.
- Production build minifies automatically (`NODE_ENV=production`/`RAILS_ENV=production`).
- The web3 bundle is large (full viem/wagmi/AppKit/WalletConnect stack); that's expected.

## Gotchas

- `eth.rb` camelizes snake_case RPC param keys (`from_block` → `fromBlock`); pass
  snake_case when calling `Client#rpc` with a params hash.
- Solidity `string` decodes to an ASCII-8BIT blob — use
  `ScaffoldEth::Reader.serialize_typed(value, type)` so it renders as text, not hex.
- ViewComponents call controller helpers via `helpers.` (e.g. `helpers.active_chain`).
- `createAppKit` is guarded in `lib/wagmi.js`; if it fails, wagmi reads/writes and the
  burner wallet still work.
