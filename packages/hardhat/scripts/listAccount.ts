import { ethers, Wallet } from "ethers";
import { config } from "hardhat";
import password from "@inquirer/password";
import { parse } from "envfile";
import * as fs from "fs";

/**
 * Decrypts the stored deployer key and prints its address + balances across the
 * configured networks. Mirrors SE-2's `yarn account`.
 */
async function main() {
  const envConfig = parse(fs.readFileSync("./.env").toString());
  const encryptedKey = envConfig.DEPLOYER_PRIVATE_KEY_ENCRYPTED;

  if (!encryptedKey) {
    console.log("🚫️ You don't have a deployer account. Run `yarn generate` or `yarn account:import` first");
    return;
  }

  const pass = await password({ message: "Enter your password to decrypt the private key:" });
  let wallet: Wallet;
  try {
    wallet = (await Wallet.fromEncryptedJson(encryptedKey, pass)) as Wallet;
  } catch (e) {
    console.log("❌ Failed to decrypt private key. Wrong password?");
    return;
  }

  console.log("Public address:", wallet.address, "\n");

  const networks = config.networks;
  for (const networkName in networks) {
    const network = networks[networkName];
    if (!("url" in network) || !network.url) continue;
    try {
      const provider = new ethers.JsonRpcProvider(network.url);
      const balance = await provider.getBalance(wallet.address);
      console.log("--", networkName, "-- 📡");
      console.log("   balance:", ethers.formatEther(balance), "ETH");
      console.log("   nonce:", await provider.getTransactionCount(wallet.address));
    } catch {
      console.log("Can't connect to network", networkName);
    }
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
