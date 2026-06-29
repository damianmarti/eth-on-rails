// Burner wallet — a throwaway local account persisted in localStorage and
// exposed as a wagmi connector. Used for fast, gas-free testing on the local
// chain (fund it from the Faucet). The analogue of SE-2's burner-connector.

import { createConnector } from "@wagmi/core";
import { privateKeyToAccount, generatePrivateKey as genPk } from "viem/accounts";
import { createWalletClient as mkWalletClient, http as httpTransport, numberToHex } from "viem";
import { activeChainId, targetNetworks, onlyLocalBurnerWallet } from "./config";

const STORAGE_KEY = "scaffoldEth.burnerWallet.pk";

export function burnerPrivateKey() {
  let pk = localStorage.getItem(STORAGE_KEY);
  if (!pk) {
    pk = genPk();
    localStorage.setItem(STORAGE_KEY, pk);
  }
  return pk;
}

export function burnerAccount() {
  return privateKeyToAccount(burnerPrivateKey());
}

export function resetBurner() {
  localStorage.removeItem(STORAGE_KEY);
}

function localNetwork() {
  const id = activeChainId();
  return targetNetworks().find((n) => n.id === id) || targetNetworks()[0];
}

// Is the burner available given config + the active network?
export function burnerAvailable() {
  const net = localNetwork();
  if (!net) return false;
  return onlyLocalBurnerWallet() ? !!net.local : true;
}

// A minimal EIP-1193 provider backed by the burner account: reads pass through
// to the RPC; signing/sending is done locally with viem.
function viemChain(net) {
  return {
    id: net.id,
    name: net.name,
    nativeCurrency: net.nativeCurrency || { name: "Ether", symbol: "ETH", decimals: 18 },
    rpcUrls: { default: { http: [net.rpcUrl] } },
  };
}

function burnerProvider(net) {
  const account = burnerAccount();
  const wallet = mkWalletClient({ account, chain: viemChain(net), transport: httpTransport(net.rpcUrl) });

  return {
    async request({ method, params }) {
      switch (method) {
        case "eth_accounts":
        case "eth_requestAccounts":
          return [account.address];
        case "eth_chainId":
          return numberToHex(net.id);
        case "eth_sendTransaction": {
          const tx = params[0] || {};
          return wallet.sendTransaction({
            account,
            to: tx.to,
            data: tx.data,
            value: tx.value ? BigInt(tx.value) : undefined,
            gas: tx.gas ? BigInt(tx.gas) : undefined,
          });
        }
        case "personal_sign": {
          const [data] = params;
          return wallet.signMessage({ account, message: { raw: data } });
        }
        case "eth_signTypedData_v4": {
          const [, json] = params;
          return wallet.signTypedData({ account, ...JSON.parse(json) });
        }
        default:
          // Pass reads straight through to the node.
          return wallet.request({ method, params });
      }
    },
    on() {},
    removeListener() {},
  };
}

export const BURNER_ID = "burnerWallet";

// wagmi connector factory for the burner account.
export function burnerConnector() {
  return createConnector((config) => {
    let connected = false;
    return {
      id: BURNER_ID,
      name: "Burner Wallet",
      type: "burnerWallet",

      async connect() {
        connected = true;
        const net = localNetwork();
        const provider = burnerProvider(net);
        const accounts = await provider.request({ method: "eth_accounts" });
        return { accounts, chainId: net.id };
      },
      async disconnect() {
        connected = false;
      },
      async getAccounts() {
        return [burnerAccount().address];
      },
      async getChainId() {
        return localNetwork().id;
      },
      async getProvider() {
        return burnerProvider(localNetwork());
      },
      async isAuthorized() {
        return connected;
      },
      onAccountsChanged() {},
      onChainChanged() {},
      onDisconnect() {
        connected = false;
        config.emitter.emit("disconnect");
      },
    };
  });
}
