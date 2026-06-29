# frozen_string_literal: true

module ScaffoldEth
  # Wallet connect / account button. Wraps Reown AppKit's web components
  # (<appkit-button> / <appkit-network-button>), initialized by the
  # `connect-button` Stimulus controller. The analogue of SE-2's
  # RainbowKitCustomConnectButton: shows connect, account, balance and the
  # current network with a switcher.
  class ConnectButtonComponent < ViewComponent::Base
    def initialize(show_balance: true)
      @show_balance = show_balance
    end
  end
end
