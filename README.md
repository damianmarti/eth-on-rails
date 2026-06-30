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
account, hit **💧** to fund it from the faucet, then visit **Example** for a guided
read/write/event walkthrough, **Debug Contracts** to interact with every function
of `YourContract`, and **Block Explorer** to inspect your transactions.

## The example page

The **Example** page (`/example`, see `app/views/example/index.html.erb`) is a small,
copy-pasteable walkthrough built entirely from the scaffold helpers. It shows the
three things every dapp does, against the sample `YourContract`:

1. **Read** the current `greeting` (live, refreshes after each transaction).
2. **Write** a new greeting (signed in your browser), with an optional ETH value
   that flips the contract's `premium` flag.
3. **Watch the change log** — every `GreetingChange` event, newest first, with the
   `greetingSetter` rendered as an Address (blockie + ENS + copy + explorer link).

Use it as the template for your own pages. The patterns it uses are documented below.

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

## Interacting with contracts

Contracts are referenced **by name** (the key in `deployed_contracts.json`, e.g.
`YourContract`) — never by hardcoded address/ABI. Reads can run either in the browser
(viem) or on the server (eth.rb); **writes are always signed in the browser**.

### Reading from a contract

**In a view (live, client-side via viem)** — the `scaffold-read-contract` controller
calls the function and writes the result into its `output` target, refreshing on a
poll and after every confirmed transaction (`watch: true`). Address results render
with the Address component automatically:

```erb
<div data-controller="scaffold-read-contract"
     data-scaffold-read-contract-contract-value="YourContract"
     data-scaffold-read-contract-function-value="greeting"
     data-scaffold-read-contract-args-value="[]"
     data-scaffold-read-contract-watch-value="true">
  <span data-scaffold-read-contract-target="output">…</span>
</div>
```

**On the server (eth.rb)** — use `ScaffoldEth::Reader` in a view, controller, or job:

```ruby
ScaffoldEth::Reader.new.read_json("YourContract", "greeting")        # => "Building Unstoppable Apps!!!"
ScaffoldEth::Reader.new.read_json("YourContract", "userGreetingCounter", "0xabc…")
```

…or hit the JSON API the controllers use:
`GET /api/read?contract=YourContract&function=greeting&args[]=0xabc…`

### Writing to a contract

Wrap your inputs and a submit button in a `scaffold-write-contract` controller. It
collects the function arguments from every `[data-scaffold-arg-input]` element inside
its scope (in DOM order, typed via `data-scaffold-arg-type`), simulates the call,
asks the wallet to sign, and shows a pending → confirmed toast (`transactor`). The
scaffold input components already emit the right data attributes:

```erb
<div data-controller="scaffold-write-contract"
     data-scaffold-write-contract-contract-value="YourContract"
     data-scaffold-write-contract-function-value="setGreeting">
  <%= render ScaffoldEth::BaseInputComponent.new(name: "newGreeting", sol_type: "string") %>

  <%# optional: ETH sent with a payable function %>
  <%= render ScaffoldEth::EtherInputComponent.new(name: "value") %>

  <button data-scaffold-write-contract-target="button"
          data-action="scaffold-write-contract#submit">Send 💸</button>
</div>
```

For typed inputs use `AddressInputComponent`, `IntegerInputComponent`,
`BytesInputComponent`, etc. — or let the Debug page's `ContractInputComponent` pick
the right one from the ABI. Writes are **never** exposed as a server endpoint.

### Getting event logs

Combine two controllers on one list: `scaffold-event-history` backfills past events
from the server (eth.rb `getLogs`, decoded) and `scaffold-watch-event` appends new
ones live (viem). Rows are de-duplicated by `txHash`/`logIndex`, and address args
render with the Address component:

```erb
<div data-controller="scaffold-event-history scaffold-watch-event"
     data-scaffold-event-history-contract-value="YourContract"
     data-scaffold-event-history-event-value="GreetingChange"
     data-scaffold-watch-event-contract-value="YourContract"
     data-scaffold-watch-event-event-value="GreetingChange">
  <table class="table table-sm">
    <thead><tr><th>Block</th><th>Change</th><th>Tx</th></tr></thead>
    <tbody data-scaffold-event-history-target="list"
           data-scaffold-watch-event-target="list"></tbody>
  </table>
</div>
```

**On the server (eth.rb)** — fetch decoded events directly:

```ruby
ScaffoldEth::Events.new.get_events("YourContract", "GreetingChange", from_block: 0)
```

…or via the API: `GET /api/events?contract=YourContract&event=GreetingChange&from_block=0`

## Deployment

The Rails app ships a Kamal config (`config/deploy.yml`) and Dockerfile (Rails 8
defaults). Set production target networks in `scaffold_eth.yml` and provide
`ALCHEMY_API_KEY` + `WALLET_CONNECT_PROJECT_ID`. Deploy contracts to a live network
with `yarn deploy --network sepolia` (Hardhat) or `RPC_URL=sepolia yarn foundry:deploy`.

## License

MIT.
