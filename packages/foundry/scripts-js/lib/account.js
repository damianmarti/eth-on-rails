/**
 * Shared encrypted-keystore helpers for the Foundry account scripts.
 * Stores an ethers encrypted JSON keystore in `.env` as DEPLOYER_PRIVATE_KEY_ENCRYPTED,
 * mirroring the Hardhat package's account flow.
 */
const fs = require("fs");
const { ethers } = require("ethers");
const { parse, stringify } = require("envfile");

const ENV_PATH = "./.env";

function readEnv() {
  return fs.existsSync(ENV_PATH) ? parse(fs.readFileSync(ENV_PATH).toString()) : {};
}

function writeEnv(config) {
  fs.writeFileSync(ENV_PATH, stringify(config));
}

async function saveEncrypted(wallet, pass) {
  const encryptedJson = await wallet.encrypt(pass);
  writeEnv({ ...readEnv(), DEPLOYER_PRIVATE_KEY_ENCRYPTED: encryptedJson });
  console.log("\n📄 Encrypted Private Key saved to packages/foundry/.env");
  console.log("🪄 Wallet address:", wallet.address);
}

module.exports = { ethers, readEnv, writeEnv, saveEncrypted, ENV_PATH };
