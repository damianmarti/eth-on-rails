import { Controller } from "@hotwired/stimulus";
import { getBalance } from "@wagmi/core";
import { formatEther } from "viem";
import { wagmiConfig } from "../lib/wagmi";
import { onAccountChange } from "../lib/account";
import { pollingInterval } from "../lib/config";

// Live native-token balance for an address (polls + refreshes on faucet/account
// change). Toggles ETH/USD. Mirrors SE-2's <Balance /> / useWatchBalance.
export default class extends Controller {
  static values = { address: String };
  static targets = ["value", "unit"];

  connect() {
    this.showUsd = false;
    this.wei = 0n;

    // If no explicit address, follow the connected account.
    if (!this.addressValue) {
      this.unsub = onAccountChange((acct) => {
        this.addressValue = acct.address || "";
        this.refresh();
      });
    }
    this.refresh();
    this.timer = setInterval(() => this.refresh(), pollingInterval());
    this.refreshHandler = () => this.refresh();
    document.addEventListener("scaffold:balance-refresh", this.refreshHandler);
  }

  disconnect() {
    clearInterval(this.timer);
    this.unsub && this.unsub();
    document.removeEventListener("scaffold:balance-refresh", this.refreshHandler);
  }

  addressValueChanged() {
    this.refresh();
  }

  async refresh() {
    if (!this.addressValue) {
      this.valueTarget.textContent = "0";
      return;
    }
    try {
      const { value } = await getBalance(wagmiConfig, { address: this.addressValue });
      this.wei = value;
      this.render();
    } catch (_) {
      this.valueTarget.textContent = "—";
    }
  }

  toggleUnit() {
    this.showUsd = !this.showUsd;
    this.render();
  }

  render() {
    const eth = Number(formatEther(this.wei));
    if (this.showUsd && this.price) {
      this.valueTarget.textContent = (eth * this.price).toFixed(2);
      if (this.hasUnitTarget) this.unitTarget.textContent = "USD";
    } else {
      this.valueTarget.textContent = eth.toFixed(4);
      if (this.hasUnitTarget) this.unitTarget.textContent = "ETH";
    }
  }
}
