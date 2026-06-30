# frozen_string_literal: true

module ScaffoldEth
  # A single zero-input view function rendered as an auto-refreshing "contract
  # variable" (name + value + refresh icon). The value is read server-side via
  # eth.rb and refreshed by the `display-variable` Stimulus controller (poll +
  # after each tx + manual refresh). Mirrors SE-2's <DisplayVariable />.
  class DisplayVariableComponent < ViewComponent::Base
    def initialize(contract:, function:)
      @contract = contract
      @function = function
    end

    def name = @function["name"]

    # Eager initial value (server-rendered) so it shows instantly.
    def initial_value
      ScaffoldEth::Reader.new(@contract.chain_id).read_json(@contract.name, name)
    rescue StandardError => e
      "⚠️ #{e.message}"
    end

    def contract_name = @contract.name
  end
end
