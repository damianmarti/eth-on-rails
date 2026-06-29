import { Controller } from "@hotwired/stimulus";

// Renders toasts for transaction lifecycle + faucet feedback. Listens for
// `scaffold:toast` events. The analogue of SE-2's useTransactor toast UI.
export default class extends Controller {
  connect() {
    this.handler = (e) => this.show(e.detail);
    document.addEventListener("scaffold:toast", this.handler);
  }

  disconnect() {
    document.removeEventListener("scaffold:toast", this.handler);
  }

  show({ type = "info", message, id, duration = 5000, href }) {
    let el = id && this.element.querySelector(`[data-toast-id="${id}"]`);
    const cls = {
      loading: "alert-info",
      success: "alert-success",
      error: "alert-error",
      info: "alert-info",
      warning: "alert-warning",
    }[type] || "alert-info";

    const icon = { loading: "⏳", success: "✅", error: "❌", warning: "⚠️", info: "ℹ️" }[type] || "ℹ️";
    const inner = `<span>${icon}</span><span>${message}</span>` +
      (href ? ` <a href="${href}" target="_blank" rel="noopener" class="underline">view</a>` : "");

    if (el) {
      el.className = `alert ${cls} shadow-lg`;
      el.innerHTML = inner;
    } else {
      el = document.createElement("div");
      el.className = `alert ${cls} shadow-lg`;
      el.innerHTML = inner;
      if (id) el.dataset.toastId = id;
      this.element.appendChild(el);
    }

    if (type !== "loading" && duration) {
      setTimeout(() => el.remove(), duration);
    }
  }
}
