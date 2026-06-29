import { Controller } from "@hotwired/stimulus";
import { onAccountChange } from "../lib/account";
import { activeChainId, targetNetworks } from "../lib/config";

// Tracks the connected chain vs the app's target network(s) and surfaces a
// "wrong network" warning. Combines SE-2's useTargetNetwork / useNetworkColor.
export default class extends Controller {
  static targets = ["warning", "name"];

  connect() {
    this.targetIds = targetNetworks().map((n) => n.id);
    this.unsub = onAccountChange((acct) => this.update(acct));
  }

  disconnect() {
    this.unsub && this.unsub();
  }

  update(acct) {
    const connected = acct.chainId;
    const wrong = connected && this.targetIds.length && !this.targetIds.includes(connected);
    if (this.hasWarningTarget) this.warningTarget.classList.toggle("hidden", !wrong);
    const net = targetNetworks().find((n) => n.id === (connected || activeChainId()));
    if (this.hasNameTarget && net) {
      this.nameTarget.textContent = net.name;
      this.nameTarget.style.color = net.color;
    }
  }
}
