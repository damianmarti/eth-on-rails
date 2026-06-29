// Tiny toast bus. Controllers call notify(...) and the transactor controller
// (mounted on #scaffold-toasts) renders them. The analogue of SE-2's
// react-hot-toast usage in useTransactor.

export function notify(type, message, opts = {}) {
  document.dispatchEvent(
    new CustomEvent("scaffold:toast", {
      detail: { type, message, id: opts.id, duration: opts.duration, href: opts.href },
    }),
  );
  return opts.id;
}

let counter = 0;
export function nextToastId() {
  return `toast-${Date.now()}-${counter++}`;
}
