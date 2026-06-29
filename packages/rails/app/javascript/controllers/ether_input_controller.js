import { Controller } from "@hotwired/stimulus";
import { parseEther } from "viem";

// ETH amount input used for a payable tx value. Keeps a human ETH string in the
// field and exposes the wei value via `weiValue()` for the write controller.
// Supports an ETH/USD display toggle. Mirrors SE-2's <EtherInput />.
export default class extends Controller {
  static targets = ["input", "prefix", "toggle"];

  connect() {
    this.usd = false;
    this.price = null;
    // Mark the wrapper so the write controller can find the payable value.
    this.element.dataset.scaffoldPayableInput = "true";
  }

  onInput() {
    // Store the parsed wei on the element for the write controller.
    try {
      this.element.dataset.wei = this.weiValue().toString();
    } catch (_) {
      delete this.element.dataset.wei;
    }
  }

  // Returns the wei BigInt for the current field value (interpreting USD if toggled).
  weiValue() {
    const raw = this.inputTarget.value.trim();
    if (!raw) return 0n;
    let eth = Number(raw);
    if (this.usd && this.price) eth = eth / this.price;
    return parseEther(eth.toString());
  }

  toggleUnit() {
    this.usd = !this.usd;
    if (this.hasPrefixTarget) this.prefixTarget.textContent = this.usd ? "$" : "Ξ";
    if (this.hasToggleTarget) {
      this.toggleTarget.textContent = this.usd ? "in USD (switch to ETH)" : "in ETH (switch to USD)";
    }
    this.onInput();
  }
}
