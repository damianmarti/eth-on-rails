import { Controller } from "@hotwired/stimulus";
import makeBlockie from "ethereum-blockies-base64";
import { onAccountChange } from "../lib/account";

// Renders the connected account (blockie + short address) into a container,
// updating live as the wallet connects/disconnects. Used on the home page.
export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.unsub = onAccountChange((acct) => this.render(acct.address));
  }

  disconnect() {
    this.unsub && this.unsub();
  }

  render(address) {
    const el = this.hasContainerTarget ? this.containerTarget : this.element;
    if (!address) {
      el.innerHTML = `<span class="text-sm opacity-60 italic">Connect your wallet</span>`;
      return;
    }
    const short = `${address.slice(0, 6)}…${address.slice(-4)}`;
    el.innerHTML = `
      <div class="inline-flex items-center gap-2">
        <img src="${makeBlockie(address)}" width="24" height="24" class="rounded-full" />
        <span class="font-mono font-medium">${short}</span>
      </div>`;
  }
}
