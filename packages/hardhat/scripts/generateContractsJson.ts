/**
 * Generates `packages/rails/config/contracts/deployed_contracts.json` from the
 * Hardhat `deployments/` directory.
 *
 * This is the ETH-on-Rails replacement for Scaffold-ETH 2's `generateTsAbis.ts`.
 * Instead of emitting a TypeScript module, it emits a language-neutral JSON file
 * that is consumed by BOTH the Ruby server layer (eth.rb ContractRegistry) and
 * the esbuild JS bundle (viem). Shape:
 *
 *   {
 *     "<chainId>": {
 *       "<ContractName>": { "address": "0x...", "abi": [ ... ] }
 *     }
 *   }
 */
import * as fs from "fs";
import * as path from "path";

const DEPLOYMENTS_DIR = path.join(__dirname, "..", "deployments");
const TARGET = path.join(__dirname, "..", "..", "rails", "config", "contracts", "deployed_contracts.json");

type ContractEntry = { address: string; abi: unknown[] };
type DeployedContracts = Record<string, Record<string, ContractEntry>>;

function getChainId(networkDir: string): string | null {
  const chainIdPath = path.join(networkDir, ".chainId");
  if (!fs.existsSync(chainIdPath)) return null;
  return fs.readFileSync(chainIdPath, "utf8").trim();
}

function collect(): DeployedContracts {
  const result: DeployedContracts = {};
  if (!fs.existsSync(DEPLOYMENTS_DIR)) return result;

  for (const network of fs.readdirSync(DEPLOYMENTS_DIR)) {
    const networkDir = path.join(DEPLOYMENTS_DIR, network);
    if (!fs.statSync(networkDir).isDirectory()) continue;

    const chainId = getChainId(networkDir);
    if (!chainId) continue;

    result[chainId] ||= {};

    for (const file of fs.readdirSync(networkDir)) {
      if (!file.endsWith(".json")) continue;
      const contractName = file.replace(/\.json$/, "");
      const data = JSON.parse(fs.readFileSync(path.join(networkDir, file), "utf8"));
      if (!data.address || !data.abi) continue;
      result[chainId][contractName] = { address: data.address, abi: data.abi };
    }
  }
  return result;
}

export function generateContractsJson(): void {
  const data = collect();
  fs.mkdirSync(path.dirname(TARGET), { recursive: true });
  fs.writeFileSync(TARGET, JSON.stringify(data, null, 2) + "\n");
  const chains = Object.keys(data);
  const total = chains.reduce((n, c) => n + Object.keys(data[c]).length, 0);
  console.log(`📝 Wrote ${total} contract(s) across chain(s) [${chains.join(", ")}] -> ${path.relative(process.cwd(), TARGET)}`);
}

if (require.main === module) {
  generateContractsJson();
}
