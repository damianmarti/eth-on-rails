// Memoized native-currency USD price fetch (from /api/price, backed by eth.rb's
// ScaffoldEth::Price / CoinGecko). Shared by the footer price pill and the
// Balance ETH/USD toggle. Refreshes at most once per minute.

let cached = null;
let fetchedAt = 0;
const TTL = 60_000;

export async function fetchPrice() {
  const now = Date.now();
  if (cached != null && now - fetchedAt < TTL) return cached;
  try {
    const res = await fetch("/api/price", { headers: { Accept: "application/json" } });
    const data = await res.json();
    cached = typeof data.price === "number" ? data.price : null;
    fetchedAt = now;
  } catch (_) {
    cached = null;
  }
  return cached;
}
