import { Controller } from "@hotwired/stimulus";
import { isAddress } from "viem";
import { notify, nextToastId } from "../lib/toast";

// Drives the standalone Faucet page form: validates the destination + amount and
// POSTs to /api/faucet (server-side eth.rb drip).
export default class extends Controller {
  static values = { url: String };
  static targets = ["amount", "button", "result"];

  async send() {
    const to = this.element.querySelector('[name="faucet_to"]')?.value?.trim();
    const amount = parseFloat(this.amountTarget.value || "1");

    if (!to || !isAddress(to)) {
      this.showResult("Enter a valid destination address", true);
      return;
    }

    const id = nextToastId();
    notify("loading", `Sending ${amount} ETH…`, { id });
    this.buttonTarget.disabled = true;

    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "",
          Accept: "application/json",
        },
        body: JSON.stringify({ address: to, amount }),
      });
      const data = await res.json();
      if (!res.ok || !data.ok) throw new Error(data.error || "Faucet request failed");
      notify("success", `Sent ${data.amount} ETH`, { id, href: `/blockexplorer/tx/${data.txHash}` });
      this.showResult(`✅ Sent! tx ${data.txHash.slice(0, 12)}…`, false);
      document.dispatchEvent(new CustomEvent("scaffold:balance-refresh"));
    } catch (err) {
      notify("error", err.message, { id });
      this.showResult(`❌ ${err.message}`, true);
    } finally {
      this.buttonTarget.disabled = false;
    }
  }

  showResult(msg, isError) {
    this.resultTarget.textContent = msg;
    this.resultTarget.classList.remove("hidden");
    this.resultTarget.classList.toggle("text-error", isError);
    this.resultTarget.classList.toggle("text-success", !isError);
  }
}
