import { Controller } from "@hotwired/stimulus";
import { collectArgs } from "../lib/args";

// Reads a view function on the SERVER via eth.rb (/api/read), showcasing the
// Ruby layer on the Debug page's read section. Args are collected from the
// inputs inside this controller's scope.
export default class extends Controller {
  static values = { contract: String, function: String };
  static targets = ["output"];

  async read() {
    const args = collectArgs(this.element).map((a) => (typeof a === "bigint" ? a.toString() : a));
    const params = new URLSearchParams();
    params.set("contract", this.contractValue);
    params.set("function", this.functionValue);
    args.forEach((a) => params.append("args[]", a));

    this.outputTarget.textContent = "…";
    try {
      const res = await fetch(`/api/read?${params.toString()}`, { headers: { Accept: "application/json" } });
      const data = await res.json();
      this.outputTarget.textContent = data.error ? `⚠️ ${data.error}` : formatValue(data.value);
    } catch (err) {
      this.outputTarget.textContent = `⚠️ ${err.message}`;
    }
  }
}

function formatValue(value) {
  if (Array.isArray(value)) return `[${value.join(", ")}]`;
  if (value && typeof value === "object") return JSON.stringify(value);
  return String(value);
}
