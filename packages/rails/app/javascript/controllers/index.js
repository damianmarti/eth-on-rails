// Registers all Stimulus controllers. The scaffold-* controllers mirror the
// Scaffold-ETH 2 React hooks (useScaffoldReadContract, useScaffoldWriteContract,
// useScaffoldWatchContractEvent, useScaffoldEventHistory, useTransactor …).

import { application } from "./application";

import ThemeController from "./theme_controller";
import ConnectButtonController from "./connect_button_controller";
import FaucetButtonController from "./faucet_button_controller";
import BlockieController from "./blockie_controller";
import AddressController from "./address_controller";
import AccountDisplayController from "./account_display_controller";
import ScaffoldBalanceController from "./scaffold_balance_controller";
import AddressInputController from "./address_input_controller";
import EtherInputController from "./ether_input_controller";
import IntegerInputController from "./integer_input_controller";
import BytesInputController from "./bytes_input_controller";
import TransactorController from "./transactor_controller";
import ScaffoldReadContractController from "./scaffold_read_contract_controller";
import ScaffoldWriteContractController from "./scaffold_write_contract_controller";
import ScaffoldWatchEventController from "./scaffold_watch_event_controller";
import ScaffoldEventHistoryController from "./scaffold_event_history_controller";
import TargetNetworkController from "./target_network_controller";
import DebugReadController from "./debug_read_controller";
import BlockStreamController from "./block_stream_controller";
import FaucetFormController from "./faucet_form_controller";
import BurnerController from "./burner_controller";
import PriceController from "./price_controller";
import DisplayVariableController from "./display_variable_controller";

application.register("theme", ThemeController);
application.register("connect-button", ConnectButtonController);
application.register("faucet-button", FaucetButtonController);
application.register("blockie", BlockieController);
application.register("address", AddressController);
application.register("account-display", AccountDisplayController);
application.register("scaffold-balance", ScaffoldBalanceController);
application.register("address-input", AddressInputController);
application.register("ether-input", EtherInputController);
application.register("integer-input", IntegerInputController);
application.register("bytes-input", BytesInputController);
application.register("transactor", TransactorController);
application.register("scaffold-read-contract", ScaffoldReadContractController);
application.register("scaffold-write-contract", ScaffoldWriteContractController);
application.register("scaffold-watch-event", ScaffoldWatchEventController);
application.register("scaffold-event-history", ScaffoldEventHistoryController);
application.register("target-network", TargetNetworkController);
application.register("debug-read", DebugReadController);
application.register("block-stream", BlockStreamController);
application.register("faucet-form", FaucetFormController);
application.register("burner", BurnerController);
application.register("price", PriceController);
application.register("display-variable", DisplayVariableController);
