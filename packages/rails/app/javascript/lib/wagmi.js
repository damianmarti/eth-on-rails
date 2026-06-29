// Sets up the wallet/web3 stack — the faithful analogue of Scaffold-ETH 2's
// wagmiConfig + RainbowKit/Reown AppKit setup, but vanilla (no React):
//   * Reown AppKit  -> wallet connection UI (<appkit-button>) + network switching
//   * @wagmi/core   -> readContract / writeContract / watchContractEvent / getBalance
//   * viem          -> underlying transport + encoding (via wagmi)
//
// The wagmi config is exported for the Stimulus controllers that mirror the
// SE-2 hooks.

import { createAppKit } from "@reown/appkit";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import * as networks from "@reown/appkit/networks";
import { http } from "@wagmi/core";
import { reconnect } from "@wagmi/core";
import { targetNetworks, walletConnectProjectId, activeChainId } from "./config";

// Map our config network keys to Reown AppKit predefined networks where possible.
const PREDEFINED = {
  hardhat: networks.hardhat,
  foundry: networks.foundry,
  mainnet: networks.mainnet,
  sepolia: networks.sepolia,
  optimism: networks.optimism,
  optimismSepolia: networks.optimismSepolia,
  arbitrum: networks.arbitrum,
  arbitrumSepolia: networks.arbitrumSepolia,
  base: networks.base,
  baseSepolia: networks.baseSepolia,
  polygon: networks.polygon,
};

// Build an AppKit/viem chain object from one serialized target network.
function toAppKitNetwork(net) {
  const predefined = PREDEFINED[net.key];
  if (predefined) return predefined;

  return networks.defineChain({
    id: net.id,
    caipNetworkId: `eip155:${net.id}`,
    chainNamespace: "eip155",
    name: net.name,
    nativeCurrency: net.nativeCurrency,
    rpcUrls: { default: { http: [net.rpcUrl], webSocket: net.wsUrl ? [net.wsUrl] : undefined } },
    blockExplorers: net.blockExplorer
      ? { default: { name: "Explorer", url: net.blockExplorer } }
      : undefined,
    testnet: !!net.testnet,
  });
}

const targets = targetNetworks();
const appKitNetworks = targets.map(toAppKitNetwork);

// Per-chain transports — honor the RPC URLs from our Rails config (Alchemy key,
// local node, rpc_overrides) instead of wagmi's default public RPCs.
const transports = {};
for (const net of targets) {
  transports[net.id] = http(net.rpcUrl);
}

const projectId = walletConnectProjectId();

export const wagmiAdapter = new WagmiAdapter({
  networks: appKitNetworks,
  projectId,
  transports,
  ssr: false,
});

export const wagmiConfig = wagmiAdapter.wagmiConfig;

const metadata = {
  name: "ETH on Rails",
  description: "A Scaffold-ETH 2 toolkit on Ruby on Rails",
  url: typeof window !== "undefined" ? window.location.origin : "http://localhost:3000",
  icons: [],
};

const defaultNetwork =
  appKitNetworks.find((n) => n.id === activeChainId()) || appKitNetworks[0];

// Initialize the Reown AppKit connect UI. Guarded so that a failure here (e.g.
// WalletConnect init with a placeholder projectId, or a blocked network) does
// NOT break the rest of the app — wagmi reads/writes and the burner wallet keep
// working regardless.
export let appKit = null;
try {
  appKit = createAppKit({
    adapters: [wagmiAdapter],
    networks: appKitNetworks,
    defaultNetwork,
    projectId,
    metadata,
    features: { analytics: false },
    enableWalletConnect: !!projectId,
  });
} catch (err) {
  // eslint-disable-next-line no-console
  console.error("[scaffold-eth] AppKit init failed:", err);
}

// Restore any previous wallet session (incl. the burner connector) on load.
try {
  reconnect(wagmiConfig).catch(() => {});
} catch (_) {}

export function targetChainObjects() {
  return appKitNetworks;
}
