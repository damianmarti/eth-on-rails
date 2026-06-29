import { task } from "hardhat/config";
import { generateContractsJson } from "../scripts/generateContractsJson";

/**
 * `hardhat generate-abis` — regenerate the Rails contracts JSON artifact
 * without redeploying (e.g. after manually editing deployments/).
 */
task("generate-abis", "Generate deployed_contracts.json for the Rails app").setAction(async () => {
  generateContractsJson();
});
