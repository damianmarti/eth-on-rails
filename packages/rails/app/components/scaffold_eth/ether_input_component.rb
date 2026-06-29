# frozen_string_literal: true

module ScaffoldEth
  # ETH amount input with an ETH/USD toggle. The `ether-input` Stimulus
  # controller converts to wei on submit. Mirrors SE-2's <EtherInput />.
  class EtherInputComponent < ViewComponent::Base
    def initialize(name:, value: nil, placeholder: "0.0", sol_type: "uint256")
      @name = name
      @value = value
      @placeholder = placeholder
      @sol_type = sol_type
    end
  end
end
