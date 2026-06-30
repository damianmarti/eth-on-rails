import { Controller } from "@hotwired/stimulus";
import { formatArgs } from "../lib/address_chip";

// Loads decoded historical events from the Rails API (/api/events, backed by
// eth.rb getLogs). The analogue of SE-2's useScaffoldEventHistory.
//
// data-scaffold-event-history-contract-value="YourContract"
// data-scaffold-event-history-event-value="GreetingChange"
export default class extends Controller {
  static values = { contract: String, event: String, fromBlock: { type: Number, default: 0 } };
  static targets = ["list", "empty"];

  connect() {
    this.load();
    this.handler = () => this.load();
    document.addEventListener("scaffold:tx-confirmed", this.handler);
  }

  disconnect() {
    document.removeEventListener("scaffold:tx-confirmed", this.handler);
  }

  async load() {
    try {
      const url = `/api/events?contract=${encodeURIComponent(this.contractValue)}` +
        `&event=${encodeURIComponent(this.eventValue)}&from_block=${this.fromBlockValue}`;
      const res = await fetch(url, { headers: { Accept: "application/json" } });
      const data = await res.json();
      this.render(data.events || []);
    } catch (_) {
      this.render([]);
    }
  }

  render(events) {
    if (!this.hasListTarget) return;
    this.listTarget.innerHTML = "";
    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", events.length > 0);

    events
      .slice()
      .reverse()
      .forEach((ev) => {
        const row = document.createElement("tr");
        row.dataset.eventKey = `${ev.transactionHash || ""}-${ev.logIndex ?? ""}`;
        row.innerHTML = `
          <td class="font-mono text-xs align-top">${ev.blockNumber ?? "-"}</td>
          <td class="text-xs align-top">${formatArgs(ev.args)}</td>
          <td class="font-mono text-xs align-top"><a class="link" href="/blockexplorer/tx/${ev.transactionHash}">${(ev.transactionHash || "").slice(0, 10)}…</a></td>`;
        this.listTarget.appendChild(row);
      });
  }
}
