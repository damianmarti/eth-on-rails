// Entry point for the esbuild bundle.
import "@hotwired/turbo-rails";

// Initialize the wallet/web3 stack (Reown AppKit + wagmi + viem) on load so the
// <appkit-button> web components render and account state is tracked app-wide.
import "./lib/wagmi";

import "./controllers";
