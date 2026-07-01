// Converts string form values into the JS types viem expects for each Solidity
// ABI type (bigint for integers, boolean for bool, arrays via JSON, etc.).
//
// Integer leaves are coerced to BigInt — including inside arrays/tuples — so a
// large uint256[] keeps full precision. NOTE: JSON.parse turns bare large
// integers into lossy JS numbers, so array/tuple integer elements should be
// entered as quoted strings (e.g. ["123...", "456..."]) to preserve precision.

const INT_RE = /^u?int\d*$/;

function toBigInt(value) {
  if (typeof value === "bigint") return value;
  if (typeof value === "string") {
    const v = value.trim();
    return v === "" ? 0n : BigInt(v);
  }
  return BigInt(value);
}

function toBool(value) {
  return value === true || value === "true" || value === "1";
}

// Recursively coerce a JSON-parsed value into the JS types viem expects, using
// the ABI type (and tuple `components` metadata when available).
function convert(value, solType, components) {
  const type = String(solType);

  if (type.endsWith("]")) {
    const inner = type.replace(/\[\d*\]$/, "");
    return Array.isArray(value) ? value.map((v) => convert(v, inner, components)) : value;
  }

  if (type.startsWith("tuple")) {
    if (!Array.isArray(components)) return value; // no metadata: pass through
    if (Array.isArray(value)) {
      return value.map((v, i) => convert(v, components[i]?.type, components[i]?.components));
    }
    if (value && typeof value === "object") {
      const out = {};
      for (const c of components) out[c.name] = convert(value[c.name], c.type, c.components);
      return out;
    }
    return value;
  }

  if (INT_RE.test(type)) return toBigInt(value);
  if (type === "bool") return toBool(value);
  return value;
}

export function parseArg(value, solType, components) {
  if (value == null) return value;
  const type = String(solType);

  // arrays / tuples -> expect JSON input
  if (type.endsWith("]") || type.startsWith("tuple")) {
    const parsed = typeof value === "string"
      ? (value.trim() === "" ? [] : JSON.parse(value.trim()))
      : value;
    return convert(parsed, type, components);
  }

  if (INT_RE.test(type)) {
    const v = String(value).trim();
    return v === "" ? 0n : BigInt(v);
  }

  if (type === "bool") return toBool(value);

  // address, string, bytes* -> pass the string through
  return value;
}

// Collect typed args from a list of elements carrying data-scaffold-arg-* attrs,
// in DOM order. Tuple component metadata may be supplied via a JSON
// data-scaffold-arg-components attribute.
export function collectArgs(scope) {
  const inputs = Array.from(scope.querySelectorAll("[data-scaffold-arg-input]"));
  return inputs.map((el) => {
    let components;
    if (el.dataset.scaffoldArgComponents) {
      try {
        components = JSON.parse(el.dataset.scaffoldArgComponents);
      } catch (_) {
        components = undefined;
      }
    }
    return parseArg(el.value, el.dataset.scaffoldArgType || "string", components);
  });
}
