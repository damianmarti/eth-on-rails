// esbuild config for the ETH-on-Rails web3 bundle.
// - dev: fast, unminified, sourcemaps, optional --watch
// - production (RAILS_ENV/NODE_ENV=production): minified
//
// The bundle is large because it includes the full web3 stack (viem, wagmi,
// Reown AppKit, WalletConnect). Minification + tree-shaking keeps prod sane.

import * as esbuild from "esbuild";

const production =
  process.env.RAILS_ENV === "production" || process.env.NODE_ENV === "production";
const watch = process.argv.includes("--watch");

const options = {
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  format: "esm",
  outdir: "app/assets/builds",
  publicPath: "/assets",
  sourcemap: true,
  minify: production,
  logLevel: "info",
  // Browser target; web3 libs ship modern ESM.
  target: ["es2022"],
  define: { "process.env.NODE_ENV": JSON.stringify(production ? "production" : "development") },
};

if (watch) {
  const ctx = await esbuild.context(options);
  await ctx.watch();
  console.log("[esbuild] watching…");
} else {
  await esbuild.build(options);
}
