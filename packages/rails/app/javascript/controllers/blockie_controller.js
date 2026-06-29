import { Controller } from "@hotwired/stimulus";
import makeBlockie from "ethereum-blockies-base64";

// Generates a deterministic blockie avatar (data-URI) for an address.
export default class extends Controller {
  static values = { address: String };

  connect() {
    this.render();
  }

  addressValueChanged() {
    this.render();
  }

  render() {
    if (!this.addressValue) return;
    try {
      this.element.src = makeBlockie(this.addressValue);
    } catch (_) {
      /* invalid address — leave placeholder */
    }
  }
}
