import { Controller } from "@hotwired/stimulus";
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
    const args = log.args || {};
    const row = document.createElement("div");
    row.className = "text-xs font-mono py-1 border-b border-base-300";
    row.textContent = JSON.stringify(args, (_, v) => (typeof v === "bigint" ? v.toString() : v));
    this.listTarget.prepend(row);
  }
}
