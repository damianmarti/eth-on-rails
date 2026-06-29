import { Controller } from "@hotwired/stimulus";
import { connectedAddress } from "../lib/account";
import { notify, nextToastId } from "../lib/toast";

// Funds the connected account from the local faucet (server-side eth.rb).
// Mirrors SE-2's FaucetButton.
export default class extends Controller {
  static values = { amount: Number, url: String };
  static targets = ["label"];

  async drip() {
    const address = connectedAddress();
    if (!address) {
      notify("warning", "Connect a wallet first");
      return;
    }

    const id = nextToastId();
    notify("loading", `Requesting ${this.amountValue || 1} ETH from faucet…`, { id });

    try {
      const res = await fetch(this.urlValue || "/api/faucet", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          Accept: "application/json",
        },
        body: JSON.stringify({ address, amount: this.amountValue || 1 }),
      });
      const data = await res.json();
      if (!res.ok || !data.ok) throw new Error(data.error || "Faucet request failed");
      notify("success", `Received ${data.amount} ETH`, { id });
      document.dispatchEvent(new CustomEvent("scaffold:balance-refresh"));
    } catch (err) {
      notify("error", err.message, { id });
    }
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || "";
  }
}
