import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { generateContractsJson } from "../scripts/generateContractsJson";

/**
 * Runs last in the deploy pipeline. Regenerates the language-neutral
 * `deployed_contracts.json` artifact consumed by the Rails app (Ruby + JS).
 * This is the ETH-on-Rails equivalent of SE-2's post-deploy TS-ABI hook.
 */
const generate: DeployFunction = async function (_hre: HardhatRuntimeEnvironment) {
  generateContractsJson();
};

export default generate;

generate.runAtTheEnd = true;
generate.tags = ["generateContractsJson"];
