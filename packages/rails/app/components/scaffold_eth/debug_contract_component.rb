# frozen_string_literal: true

module ScaffoldEth
  # Renders the auto-generated interaction UI for a single contract from its ABI:
  # an address/balance header, a Read section (server reads via eth.rb), a Write
  # section (browser-signed via viem), and an Events section. Mirrors SE-2's
  # Debug Contracts contract view.
  class DebugContractComponent < ViewComponent::Base
    def initialize(contract:)
      @contract = contract
    end

    attr_reader :contract

    def read_functions
      contract.read_functions.sort_by { |f| f["name"] }
    end

    def write_functions
      contract.write_functions.sort_by { |f| f["name"] }
    end

    def events
      contract.events.sort_by { |e| e["name"] }
    end

    def payable?(fn)
      fn["stateMutability"] == "payable"
    end

    # Read functions with zero inputs can be eagerly rendered server-side.
    def eager_value(fn)
      return nil unless fn["inputs"].empty?

      ScaffoldEth::Reader.new(contract.chain_id).read_json(contract.name, fn["name"])
    rescue StandardError => e
      "⚠️ #{e.message}"
    end
  end
end
