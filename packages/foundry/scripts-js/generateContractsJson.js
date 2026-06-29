/**
 * Foundry → Rails artifact generator.
 *
 * Parses Foundry's `broadcast/**\/run-latest.json` (deployed contract names +
 * addresses, keyed by chainId) and the compiled ABIs in `out/`, then writes the
 * SAME language-neutral artifact the Hardhat package produces:
 *
 *   packages/rails/config/contracts/deployed_contracts.json
 *
 * This is the Foundry counterpart to SE-2's `generateTsAbis.js`, emitting JSON
 * (consumed by eth.rb + viem) instead of TypeScript.
 */
const fs = require("fs");
const path = require("path");

const BROADCAST_DIR = path.join(__dirname, "..", "broadcast");
const OUT_DIR = path.join(__dirname, "..", "out");
const TARGET = path.join(__dirname, "..", "..", "rails", "config", "contracts", "deployed_contracts.json");

function findAbi(contractName) {
  // Foundry compiles to out/<Source>.sol/<ContractName>.json
  const candidate = path.join(OUT_DIR, `${contractName}.sol`, `${contractName}.json`);
  if (fs.existsSync(candidate)) {
    return JSON.parse(fs.readFileSync(candidate, "utf8")).abi;
  }
  // Fallback: scan out/ for a matching artifact
  if (!fs.existsSync(OUT_DIR)) return null;
  for (const dir of fs.readdirSync(OUT_DIR)) {
    const file = path.join(OUT_DIR, dir, `${contractName}.json`);
    if (fs.existsSync(file)) {
      return JSON.parse(fs.readFileSync(file, "utf8")).abi;
    }
  }
  return null;
}

function collect() {
  const result = {};
  if (!fs.existsSync(BROADCAST_DIR)) return result;

  // broadcast/<ScriptName>.s.sol/<chainId>/run-latest.json
  for (const script of fs.readdirSync(BROADCAST_DIR)) {
    const scriptDir = path.join(BROADCAST_DIR, script);
    if (!fs.statSync(scriptDir).isDirectory()) continue;

    for (const chainId of fs.readdirSync(scriptDir)) {
      const runLatest = path.join(scriptDir, chainId, "run-latest.json");
      if (!fs.existsSync(runLatest)) continue;

      const run = JSON.parse(fs.readFileSync(runLatest, "utf8"));
      result[chainId] ||= {};

      for (const tx of run.transactions || []) {
        if (tx.transactionType !== "CREATE" && tx.transactionType !== "CREATE2") continue;
        const name = tx.contractName;
        const address = tx.contractAddress;
        if (!name || !address) continue;
        const abi = findAbi(name);
        if (!abi) {
          console.warn(`⚠️  No ABI found in out/ for ${name}; skipping`);
          continue;
        }
        result[chainId][name] = { address, abi };
      }
    }
  }
  return result;
}

function main() {
  const data = collect();
  fs.mkdirSync(path.dirname(TARGET), { recursive: true });
  fs.writeFileSync(TARGET, JSON.stringify(data, null, 2) + "\n");
  const chains = Object.keys(data);
  const total = chains.reduce((n, c) => n + Object.keys(data[c]).length, 0);
  console.log(
    `📝 Wrote ${total} contract(s) across chain(s) [${chains.join(", ")}] -> ${path.relative(process.cwd(), TARGET)}`,
  );
}

main();
