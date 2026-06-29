# frozen_string_literal: true

module ScaffoldEth
  # Integer (uint*/int*) input with an optional "* 10^18" multiplier toggle.
  # Mirrors SE-2's <IntegerInput />.
  class IntegerInputComponent < ViewComponent::Base
    def initialize(name:, sol_type: "uint256", value: nil, placeholder: nil)
      @name = name
      @sol_type = sol_type
      @value = value
      @placeholder = placeholder || sol_type
    end

    def signed? = @sol_type.to_s.start_with?("int")
  end
end
