import { ethers } from "ethers";
import { parse, stringify } from "envfile";
import * as fs from "fs";
import password from "@inquirer/password";
import input from "@inquirer/input";

const envFilePath = "./.env";

/**
 * Import an existing private key, encrypt it, and store it in `.env`.
 * Mirrors SE-2's `yarn account:import`.
 */
async function main() {
  const privateKey = await input({ message: "Paste your private key:" });
  let wallet: ethers.Wallet;
  try {
    wallet = new ethers.Wallet(privateKey.startsWith("0x") ? privateKey : `0x${privateKey}`);
  } catch {
    console.log("❌ Invalid private key");
    return;
  }

  const pass = await password({ message: "Enter a password to encrypt your private key:" });
  const encryptedJson = await wallet.encrypt(pass);

  const existingEnvConfig = fs.existsSync(envFilePath) ? parse(fs.readFileSync(envFilePath).toString()) : {};
  fs.writeFileSync(
    envFilePath,
    stringify({ ...existingEnvConfig, DEPLOYER_PRIVATE_KEY_ENCRYPTED: encryptedJson }),
  );

  console.log("\n📄 Encrypted Private Key saved to packages/hardhat/.env file");
  console.log("🪄 Imported wallet address:", wallet.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
