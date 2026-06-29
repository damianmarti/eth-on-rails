// Loads the deployed/external contract registry from the Rails API
// (/api/contracts, backed by eth.rb's ContractRegistry) and exposes helpers to
// look up a contract's address + ABI + a specific ABI function fragment.
//
// The JS analogue of SE-2's `useDeployedContractInfo` / `contracts/deployedContracts`.

import { activeChainId } from "./config";

let registryPromise = null;

export async function loadContracts(chainId = activeChainId()) {
  if (!registryPromise) {
    registryPromise = fetch(`/api/contracts?chain_id=${chainId}`, {
      headers: { Accept: "application/json" },
    })
      .then((r) => r.json())
      .then((data) => data.contracts || {})
      .catch(() => ({}));
  }
  return registryPromise;
}

export function invalidateContracts() {
  registryPromise = null;
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
