import { Controller } from "@hotwired/stimulus";

// Light/dark theme toggle. Persists choice in localStorage and sets the
// data-theme on <html> (DaisyUI scaffoldEth / scaffoldEthDark).
export default class extends Controller {
  static targets = ["toggle"];

  connect() {
    const saved = localStorage.getItem("theme");
    const isDark = saved ? saved === "scaffoldEthDark" : matchMedia("(prefers-color-scheme: dark)").matches;
    this.apply(isDark);
    if (this.hasToggleTarget) this.toggleTarget.checked = isDark;
  }

  toggle() {
    const isDark = this.hasToggleTarget ? this.toggleTarget.checked
      : document.documentElement.dataset.theme !== "scaffoldEthDark";
    this.apply(isDark);
  }

  apply(isDark) {
    const theme = isDark ? "scaffoldEthDark" : "scaffoldEth";
    document.documentElement.dataset.theme = theme;
    localStorage.setItem("theme", theme);
  }
}
