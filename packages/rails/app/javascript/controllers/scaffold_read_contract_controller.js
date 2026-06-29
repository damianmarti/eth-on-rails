import { Controller } from "@hotwired/stimulus";
import { readContract } from "@wagmi/core";
import { wagmiConfig } from "../lib/wagmi";
import { getContract } from "../lib/contracts";
import { pollingInterval } from "../lib/config";

// Reads a view/pure function via wagmi/viem and renders the result. Optionally
// polls (watch). The analogue of SE-2's useScaffoldReadContract.
//
// data-scaffold-read-contract-contract-value="YourContract"
// data-scaffold-read-contract-function-value="greeting"
// data-scaffold-read-contract-args-value="[]"
// data-scaffold-read-contract-watch-value="true"
export default class extends Controller {
  static values = {
    contract: String,
    function: String,
    args: { type: Array, default: [] },
    watch: { type: Boolean, default: false },
  };
  static targets = ["output"];

  connect() {
    this.read();
    if (this.watchValue) {
      this.timer = setInterval(() => this.read(), pollingInterval());
      this.handler = () => this.read();
      document.addEventListener("scaffold:tx-confirmed", this.handler);
    }
  }

  disconnect() {
    clearInterval(this.timer);
    if (this.handler) document.removeEventListener("scaffold:tx-confirmed", this.handler);
  }

  async read() {
    try {
      const info = await getContract(this.contractValue);
      const result = await readContract(wagmiConfig, {
        address: info.address,
        abi: info.abi,
        functionName: this.functionValue,
        args: this.argsValue,
      });
      this.render(result);
    } catch (err) {
      this.render(`⚠️ ${err.shortMessage || err.message}`);
    }
  }

  render(value) {
    const text = typeof value === "bigint" ? value.toString() : stringify(value);
    const el = this.hasOutputTarget ? this.outputTarget : this.element;
    el.textContent = text;
  }
}

function stringify(value) {
  if (typeof value === "bigint") return value.toString();
  if (Array.isArray(value)) return `[${value.map(stringify).join(", ")}]`;
  if (value && typeof value === "object") {
    return JSON.stringify(value, (_, v) => (typeof v === "bigint" ? v.toString() : v));
  }
  return String(value);
}
