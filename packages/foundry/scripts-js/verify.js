/**
 * Verifies all contracts recorded in the Rails artifact for the given chain on
 * the configured block explorer using `forge verify-contract`.
 *
 * Usage: RPC_URL=sepolia CHAIN_ID=11155111 yarn foundry:verify
 */
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ARTIFACT = path.join(__dirname, "..", "..", "rails", "config", "contracts", "deployed_contracts.json");
const chainId = process.env.CHAIN_ID || "31337";

if (!fs.existsSync(ARTIFACT)) {
  console.error("No deployed_contracts.json found. Deploy first.");
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(ARTIFACT, "utf8"));
const contracts = data[chainId] || {};
const names = Object.keys(contracts);

if (names.length === 0) {
  console.log(`No contracts deployed on chain ${chainId} to verify.`);
  process.exit(0);
}

for (const name of names) {
  const { address } = contracts[name];
  console.log(`🔎 Verifying ${name} @ ${address} on chain ${chainId}`);
  const res = spawnSync(
    "forge",
    ["verify-contract", address, name, "--chain-id", chainId, "--watch"],
    { stdio: "inherit", env: process.env },
  );
  if (res.status !== 0) console.warn(`⚠️  Verification failed for ${name}`);
}
