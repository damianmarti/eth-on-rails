import { Controller } from "@hotwired/stimulus";

// Watches for new blocks and refreshes the explorer's first page so freshly
// mined transactions appear, without disrupting pagination on other pages.
export default class extends Controller {
  static values = { url: String, latest: Number, page: Number };

  connect() {
    this.timer = setInterval(() => this.poll(), 4000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  async poll() {
    if (this.pageValue > 1) return; // only auto-refresh page 1
    try {
      const res = await fetch(this.urlValue, { headers: { Accept: "application/json" } });
      const data = await res.json();
      if (data.latest && data.latest > this.latestValue) {
        this.latestValue = data.latest;
        if (window.Turbo) window.Turbo.visit(window.location.href, { action: "replace" });
        else window.location.reload();
      }
    } catch (_) {}
  }
}
