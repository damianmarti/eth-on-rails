// Loads the deployed/external contract registry from the Rails API
// (/api/contracts, backed by eth.rb's ContractRegistry) and exposes helpers to
// look up a contract's address + ABI + a specific ABI function fragment.
//
// The JS analogue of SE-2's `useDeployedContractInfo` / `contracts/deployedContracts`.

import { activeChainId } from "./config";

// Cache the registry per chain id — otherwise the first chain's response is
// reused for every later chain and writes/reads target the wrong addresses.
const registryByChain = new Map();

export async function loadContracts(chainId = activeChainId()) {
  if (!registryByChain.has(chainId)) {
    const promise = fetch(`/api/contracts?chain_id=${chainId}`, {
      headers: { Accept: "application/json" },
    })
      .then((r) => r.json())
      .then((data) => data.contracts || {})
      .catch(() => ({}));
    registryByChain.set(chainId, promise);
  }
  return registryByChain.get(chainId);
}

export function invalidateContracts(chainId) {
  if (chainId === undefined) {
    registryByChain.clear();
  } else {
    registryByChain.delete(chainId);
  }
}

export async function getContract(name, chainId) {
  const contracts = await loadContracts(chainId);
  const info = contracts[name];
  if (!info) throw new Error(`Contract "${name}" not found in registry`);
  return info; // { name, address, abi, chainId }
}

export async function getAbiFunction(name, functionName, chainId) {
  const info = await getContract(name, chainId);
  const fn = info.abi.find((e) => e.type === "function" && e.name === functionName);
  if (!fn) throw new Error(`Function "${functionName}" not found on "${name}"`);
  return { info, fn };
}

export async function getAbiEvent(name, eventName, chainId) {
  const info = await getContract(name, chainId);
  const ev = info.abi.find((e) => e.type === "event" && e.name === eventName);
  if (!ev) throw new Error(`Event "${eventName}" not found on "${name}"`);
  return { info, ev };
}
