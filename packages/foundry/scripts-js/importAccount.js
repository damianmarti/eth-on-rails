const password = require("@inquirer/password").default;
const input = require("@inquirer/input").default;
const { ethers, saveEncrypted } = require("./lib/account");

async function main() {
  const pk = await input({ message: "Paste your private key:" });
  let wallet;
  try {
    wallet = new ethers.Wallet(pk.startsWith("0x") ? pk : `0x${pk}`);
  } catch {
    console.log("❌ Invalid private key");
    return;
  }
  const pass = await password({ message: "Enter a password to encrypt your private key:" });
  await saveEncrypted(wallet, pass);
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
