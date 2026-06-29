import { Controller } from "@hotwired/stimulus";

// Integer (uint*/int*) input with validation + an optional "* 10^18" multiplier
// toggle. Mirrors SE-2's <IntegerInput />.
export default class extends Controller {
  static targets = ["input", "error", "multiply"];

  connect() {
    this.multiplied = false;
  }

  validate() {
    const v = this.inputTarget.value.trim();
    this.clearError();
    if (v === "") return;
    if (!/^-?\d+$/.test(v)) {
      this.showError("Enter a whole number");
    }
  }

  toggleMultiply() {
    const v = this.inputTarget.value.trim();
    if (!/^-?\d+$/.test(v)) return;
    this.multiplied = !this.multiplied;
    if (this.multiplied) {
      this.inputTarget.value = (BigInt(v) * 10n ** 18n).toString();
    } else {
      try {
        this.inputTarget.value = (BigInt(v) / 10n ** 18n).toString();
      } catch (_) {}
    }
    if (this.hasMultiplyTarget) this.multiplyTarget.classList.toggle("text-primary", this.multiplied);
  }

  showError(msg) {
    if (!this.hasErrorTarget) return;
    this.errorTarget.textContent = msg;
    this.errorTarget.classList.remove("hidden");
  }

  clearError() {
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden");
  }
}
