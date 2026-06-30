// Renders an address exactly like the server-side ScaffoldEth::AddressComponent
// (blockie + shortened address + copy + explorer link). Used by controllers that
// render values dynamically (display-variable, debug-read, event history) so that
// address-typed values always use the Address component look + behavior.
//
// The injected markup carries data-controller="address", so Stimulus attaches the
// `address` controller (copy button) to it automatically.

import makeBlockie from "ethereum-blockies-base64";
import { targetNetworks, activeChainId } from "./config";

export function isAddressValue(v) {
  return typeof v === "string" && /^0x[0-9a-fA-F]{40}$/.test(v);
}

function activeNetwork() {
  return targetNetworks().find((n) => n.id === activeChainId());
}

function explorerUrl(address) {
  const net = activeNetwork();
  if (net && net.blockExplorer) return `${net.blockExplorer}/address/${address}`;
  return `/blockexplorer/address/${address}`;
}

const sizeClass = { xs: "text-xs", sm: "text-sm", base: "text-base", lg: "text-lg" };
const sizePx = { xs: 16, sm: 20, base: 24, lg: 32 };

// Render a read/return value into `el`: address-typed values use the Address
// component markup; arrays of addresses render as chips; everything else is text.
export function renderValue(el, value) {
  if (isAddressValue(value)) {
    el.innerHTML = addressChipHTML(value);
  } else if (Array.isArray(value) && value.length && value.every(isAddressValue)) {
    el.innerHTML = value.map((a) => addressChipHTML(a)).join(" ");
  } else if (Array.isArray(value)) {
    el.textContent = `[${value.join(", ")}]`;
  } else if (value && typeof value === "object") {
    el.textContent = JSON.stringify(value);
  } else {
    el.textContent = String(value);
  }
}

// Render an event args object as "name: value" pairs, with address values shown
// as Address chips. Returns an HTML string.
export function formatArgs(args) {
  if (!args || typeof args !== "object") return escapeHtml(String(args));
  return Object.entries(args)
    .map(([k, v]) => {
      const val = isAddressValue(v) ? addressChipHTML(v, { size: "xs" }) : escapeHtml(formatScalar(v));
      return `<span class="opacity-60">${escapeHtml(k)}:</span> ${val}`;
    })
    .join('<span class="opacity-40 mx-1">·</span>');
}

function formatScalar(v) {
  if (Array.isArray(v)) return `[${v.join(", ")}]`;
  if (v && typeof v === "object") return JSON.stringify(v);
  return String(v);
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c],
  );
}

export function addressChipHTML(address, { size = "sm" } = {}) {
  if (!isAddressValue(address)) return null;
  const short = `${address.slice(0, 6)}…${address.slice(-4)}`;
  const px = sizePx[size] || 20;
  const txt = sizeClass[size] || "text-sm";
  const net = activeNetwork();
  const external = !!(net && net.blockExplorer);
  const target = external ? ' target="_blank" rel="noopener"' : "";
  return `<span class="inline-flex items-center gap-1.5" data-controller="address" data-address-value="${address}">
    <img src="${makeBlockie(address)}" width="${px}" height="${px}" class="rounded-full bg-base-300 shrink-0" alt="" />
    <a href="${explorerUrl(address)}" class="font-mono font-medium ${txt} hover:underline"${target}>${short}</a>
    <button type="button" class="opacity-60 hover:opacity-100" title="Copy address" data-action="address#copy">
      <span data-address-target="copyIcon">📋</span>
    </button>
  </span>`;
}
