const password = require("@inquirer/password").default;
const { ethers, readEnv } = require("./lib/account");

const NETWORKS = {
  mainnet: process.env.ALCHEMY_API_KEY && `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
  sepolia: process.env.ALCHEMY_API_KEY && `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
};

async function main() {
  const encrypted = readEnv().DEPLOYER_PRIVATE_KEY_ENCRYPTED;
  if (!encrypted) {
    console.log("🚫️ No deployer account. Run `yarn foundry:account:generate` first");
    return;
  }
  const pass = await password({ message: "Enter your password to decrypt the private key:" });
  const wallet = await ethers.Wallet.fromEncryptedJson(encrypted, pass);
  console.log("Public address:", wallet.address, "\n");

  for (const [name, url] of Object.entries(NETWORKS)) {
    if (!url) continue;
    try {
      const provider = new ethers.JsonRpcProvider(url);
      const balance = await provider.getBalance(wallet.address);
      console.log(`-- ${name} 📡  balance: ${ethers.formatEther(balance)} ETH`);
    } catch {
      console.log(`Can't connect to ${name}`);
    }
  }
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
