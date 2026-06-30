import { Controller } from "@hotwired/stimulus";
import { pollingInterval } from "../lib/config";
import { renderValue } from "../lib/address_chip";

// Auto-refreshing contract variable (zero-input view fn). Reads server-side via
// eth.rb (/api/read): polls, refreshes after each confirmed tx, and on the
// manual refresh icon. Mirrors SE-2's DisplayVariable (which refetches on block).
export default class extends Controller {
  static values = { contract: String, function: String };
  static targets = ["output", "refresh"];

  connect() {
    this.timer = setInterval(() => this.refresh(true), pollingInterval());
    this.txHandler = () => this.refresh(true);
    document.addEventListener("scaffold:tx-confirmed", this.txHandler);
  }

  disconnect() {
    clearInterval(this.timer);
    document.removeEventListener("scaffold:tx-confirmed", this.txHandler);
  }

  async refresh(silent = false) {
    if (!silent && this.hasRefreshTarget) this.refreshTarget.classList.add("animate-spin");
    try {
      const params = new URLSearchParams({ contract: this.contractValue, function: this.functionValue });
      const res = await fetch(`/api/read?${params.toString()}`, { headers: { Accept: "application/json" } });
      const data = await res.json();
      if (data.error) {
        this.outputTarget.textContent = `⚠️ ${data.error}`;
      } else {
        renderValue(this.outputTarget, data.value);
      }
    } catch (_) {
      /* keep the previous value on transient errors */
    } finally {
      if (this.hasRefreshTarget) this.refreshTarget.classList.remove("animate-spin");
    }
  }
}

