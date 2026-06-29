import { Controller } from "@hotwired/stimulus";

// Copy-to-clipboard for an address display.
export default class extends Controller {
  static values = { address: String };
  static targets = ["copyIcon"];

  async copy() {
    try {
      await navigator.clipboard.writeText(this.addressValue);
      if (this.hasCopyIconTarget) {
        const prev = this.copyIconTarget.textContent;
        this.copyIconTarget.textContent = "✅";
        setTimeout(() => (this.copyIconTarget.textContent = prev), 1200);
      }
    } catch (_) {}
  }
}
