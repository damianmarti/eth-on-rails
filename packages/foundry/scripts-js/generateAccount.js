const password = require("@inquirer/password").default;
const qrcode = require("qrcode");
const { ethers, readEnv, saveEncrypted } = require("./lib/account");

async function main() {
  if (readEnv().DEPLOYER_PRIVATE_KEY_ENCRYPTED) {
    console.log("⚠️ You already have a deployer account in packages/foundry/.env");
    return;
  }
  const wallet = ethers.Wallet.createRandom();
  const pass = await password({ message: "Enter a password to encrypt your private key:" });
  await saveEncrypted(wallet, pass);
  console.log("\nFund this address:");
  console.log(await qrcode.toString(wallet.address, { type: "terminal", small: true }));
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
