// Shared connected-account state. Wraps wagmi's watchAccount so any Stimulus
// controller can read the current address/chain and subscribe to changes —
// the analogue of SE-2's useAccount / useTargetNetwork wiring.

import { getAccount, watchAccount, watchChainId } from "@wagmi/core";
import { wagmiConfig } from "./wagmi";

const listeners = new Set();

export function currentAccount() {
  return getAccount(wagmiConfig);
}

export function connectedAddress() {
  return currentAccount().address || null;
}

export function connectedChainId() {
  return currentAccount().chainId;
}

// Subscribe to account OR chain changes. Returns an unsubscribe fn.
export function onAccountChange(callback) {
  listeners.add(callback);
  // Fire immediately with current state.
  try {
    callback(currentAccount());
  } catch (_) {}
  return () => listeners.delete(callback);
}

function broadcast() {
  const acct = currentAccount();
  listeners.forEach((cb) => {
    try {
      cb(acct);
    } catch (_) {}
  });
}

// Bridge wagmi watchers to our listener set + a DOM event for non-importers.
watchAccount(wagmiConfig, { onChange: broadcast });
watchChainId(wagmiConfig, {
  onChange: () => {
    broadcast();
    document.dispatchEvent(new CustomEvent("scaffold:chain-changed"));
  },
});
