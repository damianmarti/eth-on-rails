import { Controller } from "@hotwired/stimulus";
import { formatArgs } from "../lib/address_chip";
import { watchContractEvent } from "@wagmi/core";
import { wagmiConfig } from "../lib/wagmi";
import { getContract } from "../lib/contracts";

// Live-subscribes to a contract event and prepends decoded logs into a list.
// The analogue of SE-2's useScaffoldWatchContractEvent.
//
// data-scaffold-watch-event-contract-value="YourContract"
// data-scaffold-watch-event-event-value="GreetingChange"
export default class extends Controller {
  static values = { contract: String, event: String };
  static targets = ["list"];

  async connect() {
    const info = await getContract(this.contractValue);
    this.unwatch = watchContractEvent(wagmiConfig, {
      address: info.address,
      abi: info.abi,
      eventName: this.eventValue,
      onLogs: (logs) => logs.forEach((log) => this.prepend(log)),
    });
  }

  disconnect() {
    this.unwatch && this.unwatch();
  }

  prepend(log) {
    if (!this.hasListTarget) return;
    const hash = log.transactionHash || "";
    const key = `${hash}-${log.logIndex ?? ""}`;
    // Skip if this event is already shown (e.g. also rendered by event-history).
    if (this.listTarget.querySelector(`[data-event-key="${key}"]`)) return;

    // Normalize bigints to strings so address detection / display work.
    const args = {};
    for (const [k, v] of Object.entries(log.args || {})) args[k] = typeof v === "bigint" ? v.toString() : v;
    const row = document.createElement("tr");
    row.dataset.eventKey = key;
    row.innerHTML = `
      <td class="font-mono text-xs align-top">${log.blockNumber ?? "-"}</td>
      <td class="text-xs align-top">${formatArgs(args)}</td>
      <td class="font-mono text-xs align-top"><a class="link" href="/blockexplorer/tx/${hash}">${hash.slice(0, 10)}…</a></td>`;
    this.listTarget.prepend(row);
  }
}
