// Converts string form values into the JS types viem expects for each Solidity
// ABI type (bigint for integers, boolean for bool, arrays via JSON, etc.).

export function parseArg(value, solType) {
  if (value == null) return value;
  const type = String(solType);

  // arrays / tuples -> expect JSON input
  if (type.endsWith("]") || type.startsWith("tuple")) {
    if (typeof value !== "string") return value;
    const trimmed = value.trim();
    return trimmed === "" ? [] : JSON.parse(trimmed);
  }

  if (/^u?int\d*$/.test(type)) {
    const v = String(value).trim();
    return v === "" ? 0n : BigInt(v);
  }

  if (type === "bool") {
    return value === true || value === "true" || value === "1";
  }

  // address, string, bytes* -> pass the string through
  return value;
}

// Collect typed args from a list of elements carrying data-scaffold-arg-* attrs,
// in DOM order.
export function collectArgs(scope) {
  const inputs = Array.from(scope.querySelectorAll("[data-scaffold-arg-input]"));
  return inputs.map((el) => parseArg(el.value, el.dataset.scaffoldArgType || "string"));
}
