import { Controller } from "@hotwired/stimulus";
import { isAddress, getAddress } from "viem";
import makeBlockie from "ethereum-blockies-base64";

// Validates an address and resolves ENS names (via /api/ens). Mirrors
// SE-2's <AddressInput />.
export default class extends Controller {
  static targets = ["input", "error", "ens", "blockie"];

  validate() {
    const value = this.inputTarget.value.trim();
    this.clear();
    if (!value) return;

    if (value.endsWith(".eth")) {
      this.resolveEns(value);
      return;
    }
    if (isAddress(value)) {
      this.showBlockie(getAddress(value));
    } else {
      this.showError("Invalid address");
    }
  }

  async resolveEns(name) {
    try {
      const res = await fetch(`/api/ens?name=${encodeURIComponent(name)}`);
      const data = await res.json();
      if (data.address) {
        // Replace the field value with the resolved address for submission.
        this.inputTarget.value = data.address;
        this.showBlockie(data.address);
        this.ensTarget.textContent = `${name} → ${data.address.slice(0, 6)}…${data.address.slice(-4)}`;
        this.ensTarget.classList.remove("hidden");
      } else {
        this.showError("Could not resolve ENS name");
      }
    } catch (_) {
      this.showError("ENS lookup failed");
    }
  }

  showBlockie(address) {
    if (!this.hasBlockieTarget) return;
    this.blockieTarget.innerHTML = `<img src="${makeBlockie(address)}" width="20" height="20" class="rounded-full" />`;
    this.blockieTarget.classList.remove("hidden");
  }

  showError(msg) {
    if (!this.hasErrorTarget) return;
    this.errorTarget.textContent = msg;
    this.errorTarget.classList.remove("hidden");
  }

  clear() {
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden");
    if (this.hasEnsTarget) this.ensTarget.classList.add("hidden");
    if (this.hasBlockieTarget) this.blockieTarget.classList.add("hidden");
  }
}
