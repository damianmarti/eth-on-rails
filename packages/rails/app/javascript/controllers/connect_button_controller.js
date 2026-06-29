import { Controller } from "@hotwired/stimulus";
import { onAccountChange } from "../lib/account";

// Hooks the Reown AppKit <appkit-button> into our account state. AppKit renders
// the connect/account UI itself; this controller just reacts to connection
// changes (e.g. to surface a "wrong network" hint). Mirrors SE-2's
// RainbowKitCustomConnectButton wiring.
export default class extends Controller {
  static targets = ["network", "button"];

  connect() {
    this.unsub = onAccountChange((acct) => this.update(acct));
  }

  disconnect() {
    this.unsub && this.unsub();
  }

  update(acct) {
    // Broadcast a normalized event other controllers (balance, account-display) use.
    document.dispatchEvent(
      new CustomEvent("scaffold:account", {
        detail: { address: acct.address || null, chainId: acct.chainId, status: acct.status },
      }),
    );
  }
}
