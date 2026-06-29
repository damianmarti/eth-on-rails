import { Controller } from "@hotwired/stimulus";
import { connect, disconnect, getAccount } from "@wagmi/core";
import { wagmiConfig } from "../lib/wagmi";
import { burnerConnector, burnerAccount, burnerAvailable, resetBurner, BURNER_ID } from "../lib/burner";
import { notify } from "../lib/toast";

// "Burner Wallet" connect button, shown only on local networks. Connects the
// in-browser burner account via wagmi so all reads/writes use it.
export default class extends Controller {
  static targets = ["label", "address"];

  connect() {
    if (!burnerAvailable()) {
      this.element.classList.add("hidden");
      return;
    }
    this.update(getAccount(wagmiConfig));
  }

  async toggle() {
    const acct = getAccount(wagmiConfig);
    if (acct.connector?.id === BURNER_ID) {
      await disconnect(wagmiConfig);
      this.update(getAccount(wagmiConfig));
      return;
    }
    try {
      await connect(wagmiConfig, { connector: burnerConnector() });
      notify("success", "Burner wallet connected");
      this.update(getAccount(wagmiConfig));
    } catch (err) {
      notify("error", err.shortMessage || err.message);
    }
  }

  newBurner() {
    resetBurner();
    notify("info", `New burner: ${burnerAccount().address.slice(0, 10)}…`);
  }

  update(acct) {
    const isBurner = acct.connector?.id === BURNER_ID;
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = isBurner ? "Disconnect burner" : "Burner Wallet";
    }
    if (this.hasAddressTarget) {
      this.addressTarget.textContent = isBurner ? `${acct.address.slice(0, 6)}…${acct.address.slice(-4)}` : "";
    }
  }
}
