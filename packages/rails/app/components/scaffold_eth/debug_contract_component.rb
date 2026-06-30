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

    # Zero-input view functions shown in the left "Contract Variables" card (SE-2).
    def variable_functions
      contract.read_functions.select { |f| f["inputs"].empty? }.sort_by { |f| f["name"] }
    end

    # Read functions that take inputs — shown in the right "Read" card.
    def read_functions
      contract.read_functions.reject { |f| f["inputs"].empty? }.sort_by { |f| f["name"] }
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
  end
end
