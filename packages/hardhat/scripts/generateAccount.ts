import { ethers } from "ethers";
import { parse, stringify } from "envfile";
import * as fs from "fs";
import password from "@inquirer/password";
import qrcode from "qrcode";

const envFilePath = "./.env";

/**
 * Generate a new random private key, encrypt it, and store it in `.env` as
 * `DEPLOYER_PRIVATE_KEY_ENCRYPTED`. Mirrors SE-2's `yarn generate`.
 */
async function setNewEnvConfig(existingEnvConfig = {}) {
  const randomWallet = ethers.Wallet.createRandom();

  const pass = await password({ message: "Enter a password to encrypt your private key:" });
  const encryptedJson = await randomWallet.encrypt(pass);

  const newEnvConfig = {
    ...existingEnvConfig,
    DEPLOYER_PRIVATE_KEY_ENCRYPTED: encryptedJson,
  };

  fs.writeFileSync(envFilePath, stringify(newEnvConfig));
  console.log("\n📄 Encrypted Private Key saved to packages/hardhat/.env file");
  console.log("🪄 Generated wallet address:", randomWallet.address);

  console.log("\nScan this QR code to fund the address on a faucet/wallet:");
  console.log(await qrcode.toString(randomWallet.address, { type: "terminal", small: true }));
}

async function main() {
  if (!fs.existsSync(envFilePath)) {
    await setNewEnvConfig();
    return;
  }
  const existingEnvConfig = parse(fs.readFileSync(envFilePath).toString());
  if (existingEnvConfig.DEPLOYER_PRIVATE_KEY_ENCRYPTED) {
    console.log("⚠️ You already have a deployer account. Check the packages/hardhat/.env file");
    return;
  }
  await setNewEnvConfig(existingEnvConfig);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
