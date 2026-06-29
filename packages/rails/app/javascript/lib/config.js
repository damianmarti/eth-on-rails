// Reads the scaffold config that Rails injected into the page
// (<meta name="scaffold-eth-config">), which is serialized from
// ScaffoldEth::Config#to_browser_json. This is the JS side of the
// scaffold.config.ts bridge.

let cached = null;

export function scaffoldConfig() {
  if (cached) return cached;
  const meta = document.querySelector('meta[name="scaffold-eth-config"]');
  cached = meta ? JSON.parse(meta.content) : { targetNetworks: [], activeChainId: 31337 };
  return cached;
}

export function targetNetworks() {
  return scaffoldConfig().targetNetworks || [];
}

export function activeChainId() {
  return scaffoldConfig().activeChainId;
}

export function pollingInterval() {
  return scaffoldConfig().pollingInterval || 30000;
}

export function walletConnectProjectId() {
  return scaffoldConfig().walletConnectProjectId;
}

export function onlyLocalBurnerWallet() {
  return !!scaffoldConfig().onlyLocalBurnerWallet;
}
