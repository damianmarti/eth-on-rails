import { Controller } from "@hotwired/stimulus";
import { simulateContract, writeContract, waitForTransactionReceipt } from "@wagmi/core";
import { wagmiConfig } from "../lib/wagmi";
import { getContract } from "../lib/contracts";
import { connectedAddress } from "../lib/account";
import { collectArgs } from "../lib/args";
import { notify, nextToastId } from "../lib/toast";

// Sends a state-changing transaction, signed by the connected wallet, with the
// full toast lifecycle (simulating → pending → confirmed/error). Combines
// SE-2's useScaffoldWriteContract + useTransactor.
//
// data-scaffold-write-contract-contract-value="YourContract"
// data-scaffold-write-contract-function-value="setGreeting"
// Args are collected from [data-scaffold-arg-input] inside the form/controller
// scope; an optional payable value from [data-scaffold-payable-input].
export default class extends Controller {
  static values = { contract: String, function: String };
  static targets = ["button"];

  async submit(event) {
    event && event.preventDefault();

    if (!connectedAddress()) {
      notify("warning", "Connect a wallet to send transactions");
      return;
    }

    const args = collectArgs(this.element);
    const value = this.payableValue();
    const id = nextToastId();

    this.setBusy(true);
    notify("loading", `Awaiting signature for ${this.functionValue}…`, { id });

    try {
      const info = await getContract(this.contractValue);
      const base = {
        address: info.address,
        abi: info.abi,
        functionName: this.functionValue,
        args,
        account: connectedAddress(),
      };
      if (value > 0n) base.value = value;

      // Simulate first for a friendly revert reason (like SE-2).
      const { request } = await simulateContract(wagmiConfig, base);
      const hash = await writeContract(wagmiConfig, request);

      notify("loading", "Transaction sent, waiting for confirmation…", { id });
      const receipt = await waitForTransactionReceipt(wagmiConfig, { hash });

      notify("success", `Confirmed in block ${receipt.blockNumber}`, { id, href: this.txHref(hash) });
      document.dispatchEvent(new CustomEvent("scaffold:tx-confirmed", { detail: { hash, receipt } }));
    } catch (err) {
      notify("error", err.shortMessage || err.message, { id });
    } finally {
      this.setBusy(false);
    }
  }

  payableValue() {
    const el = this.element.querySelector("[data-scaffold-payable-input]");
    if (!el || !el.dataset.wei) return 0n;
    try {
      return BigInt(el.dataset.wei);
    } catch (_) {
      return 0n;
    }
  }

  txHref(hash) {
    return `/blockexplorer/tx/${hash}`;
  }

  setBusy(busy) {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = busy;
      this.buttonTarget.classList.toggle("loading", busy);
    }
  }
}
