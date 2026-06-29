/**
 * Thin wrapper around `forge script script/Deploy.s.sol`.
 * Selects the RPC endpoint (defaults to localhost) and broadcasts.
 * After this runs, `generateContractsJson.js` produces the Rails artifact.
 */
const { spawnSync } = require("child_process");

const rpcUrl = process.env.RPC_URL || "localhost";
const args = [
  "script",
  "script/Deploy.s.sol",
  "--rpc-url",
  rpcUrl,
  "--broadcast",
  "--legacy",
  "-vvv",
];

console.log(`🚀 forge ${args.join(" ")}`);
const res = spawnSync("forge", args, { stdio: "inherit", env: process.env });
process.exit(res.status ?? 0);
