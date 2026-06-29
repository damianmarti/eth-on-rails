import { Controller } from "@hotwired/stimulus";

// Polls /api/blocks and prepends newly-mined blocks to the explorer table for a
// live feel (the lightweight alternative to a full Turbo Stream indexer).
export default class extends Controller {
  static values = { url: String };
  static targets = ["list"];

  connect() {
    this.latest = this.currentTop();
    this.timer = setInterval(() => this.poll(), 4000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  currentTop() {
    const first = this.hasListTarget && this.listTarget.querySelector("td a");
    return first ? parseInt(first.textContent.replace("#", ""), 10) : 0;
  }

  async poll() {
    try {
      const res = await fetch(`${this.urlValue}?since=${this.latest}`, { headers: { Accept: "application/json" } });
      const data = await res.json();
      (data.blocks || [])
        .sort((a, b) => a.number - b.number)
        .forEach((b) => this.prepend(b));
      if (data.latest) this.latest = data.latest;
    } catch (_) {}
  }

  prepend(b) {
    if (!this.hasListTarget) return;
    const row = document.createElement("tr");
    row.className = "bg-success/10";
    const ageDate = new Date(b.timestamp * 1000);
    row.innerHTML = `
      <td><a class="link link-primary font-mono" href="/blockexplorer/block/${b.number}">#${b.number}</a></td>
      <td class="text-xs opacity-70">${ageDate.toLocaleTimeString()}</td>
      <td>${b.tx_count}</td>
      <td class="font-mono text-xs">${b.gas_used?.toLocaleString?.() ?? b.gas_used}</td>
      <td class="font-mono text-xs"><a class="link" href="/blockexplorer/address/${b.miner}">${(b.miner || "").slice(0, 6)}…${(b.miner || "").slice(-4)}</a></td>`;
    this.listTarget.prepend(row);
  }
}
