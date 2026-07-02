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

    if (!el) {
      el = document.createElement("div");
      if (id) el.dataset.toastId = id;
      this.element.appendChild(el);
    }
    el.className = `alert ${cls} shadow-lg`;
    this.renderInto(el, icon, message, href);

    if (type !== "loading" && duration) {
      setTimeout(() => el.remove(), duration);
    }
  }

  // Builds toast content from DOM nodes (never innerHTML): `message` and `href`
  // come from wallet/API errors and must be treated as untrusted.
  renderInto(el, icon, message, href) {
    const iconSpan = document.createElement("span");
    iconSpan.textContent = icon;
    const msgSpan = document.createElement("span");
    msgSpan.textContent = message == null ? "" : String(message);
    const nodes = [iconSpan, msgSpan];

    const safeHref = this.safeHref(href);
    if (safeHref) {
      const link = document.createElement("a");
      link.href = safeHref;
      link.target = "_blank";
      link.rel = "noopener";
      link.className = "underline";
      link.textContent = "view";
      nodes.push(document.createTextNode(" "), link);
    }

    el.replaceChildren(...nodes);
  }

  // Allow only same-origin paths or http(s) URLs; reject javascript:, data:, etc.
  safeHref(href) {
    if (!href) return null;
    try {
      const url = new URL(href, window.location.origin);
      if (url.protocol === "http:" || url.protocol === "https:") return url.href;
    } catch (_) {
      return null;
    }
    return null;
  }
}
