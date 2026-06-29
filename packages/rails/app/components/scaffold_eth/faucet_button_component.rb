# frozen_string_literal: true

module ScaffoldEth
  # Quick-faucet button in the header. Funds the connected account from the local
  # faucet (eth.rb, server-side). Only meaningful on local chains. Mirrors SE-2's
  # FaucetButton.
  class FaucetButtonComponent < ViewComponent::Base
    def initialize(amount: 1)
      @amount = amount
    end
  end
end
