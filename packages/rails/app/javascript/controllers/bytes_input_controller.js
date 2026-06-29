import { Controller } from "@hotwired/stimulus";
import { isHex } from "viem";

// Validates 0x-hex bytes input; enforces fixed length for bytesN. Mirrors
// SE-2's <BytesInput /> / <Bytes32Input />.
export default class extends Controller {
  static targets = ["input", "error"];
  static values = { length: Number };

  validate() {
    const v = this.inputTarget.value.trim();
    this.clearError();
    if (v === "") return;
    if (!isHex(v)) {
      this.showError("Expected 0x-prefixed hex");
      return;
    }
    if (this.lengthValue) {
      const byteLen = (v.length - 2) / 2;
      if (byteLen !== this.lengthValue) {
        this.showError(`Expected ${this.lengthValue} bytes, got ${byteLen}`);
      }
    }
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
