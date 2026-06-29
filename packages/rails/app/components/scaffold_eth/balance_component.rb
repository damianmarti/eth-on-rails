# frozen_string_literal: true

module ScaffoldEth
  # Live native-token balance for an address. The `scaffold-balance` Stimulus
  # controller fetches + polls it via wagmi/viem and toggles ETH/USD. Mirrors
  # SE-2's <Balance />. If `address` is nil it renders nothing until the
  # connected account is injected client-side.
  class BalanceComponent < ViewComponent::Base
    def initialize(address: nil, class_name: "")
      @address = address
      @class_name = class_name
    end
  end
end
