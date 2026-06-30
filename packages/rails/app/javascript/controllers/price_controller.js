import { Controller } from "@hotwired/stimulus";
import { fetchPrice } from "../lib/price";

// Fills the footer native-currency price pill from /api/price. Hides itself when
// no price is available. Mirrors SE-2's footer price.
export default class extends Controller {
  static targets = ["value"];

  connect() {
    this.load();
    this.timer = setInterval(() => this.load(), 60_000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  async load() {
    const price = await fetchPrice();
    if (price == null) {
      this.element.classList.add("hidden");
      return;
    }
    this.element.classList.remove("hidden");
    this.valueTarget.textContent = price.toLocaleString(undefined, {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }
}
