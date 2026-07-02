# frozen_string_literal: true

module ScaffoldEth
  # Local-network faucet. Holds a well-known funded dev key (anvil/hardhat
  # account #0) and sends ETH to a target address via eth.rb. The Ruby analogue
  # of SE-2's local Faucet — only enabled on local chains.
  module Faucet
    # Default anvil/hardhat account #0 private key (publicly known dev key).
    DEFAULT_FAUCET_PRIVATE_KEY =
      "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

    DEFAULT_AMOUNT_ETH = BigDecimal("1")
    # Hard cap on a single drip so a malformed/hostile request can't drain the
    # dev key in one call.
    MAX_AMOUNT_ETH = BigDecimal("100")

    class NotAvailable < StandardError; end
    class InvalidAmount < StandardError; end

    class << self
      def available?(chain = ScaffoldEth::Config.active_chain)
        chain.local?
      end

      # Coerce to BigDecimal and enforce finite/positive/capped. Returns the
      # validated BigDecimal or raises InvalidAmount.
      def validate_amount!(amount)
        decimal = amount.is_a?(BigDecimal) ? amount : BigDecimal(amount.to_s)
        raise InvalidAmount, "Amount must be a finite number" unless decimal.finite?
        raise InvalidAmount, "Amount must be greater than zero" unless decimal.positive?
        raise InvalidAmount, "Amount exceeds the #{MAX_AMOUNT_ETH.to_s('F')} ETH limit" if decimal > MAX_AMOUNT_ETH

        decimal
      rescue ArgumentError
        raise InvalidAmount, "Amount is not a valid number"
      end

      def faucet_key
        @faucet_key ||= ::Eth::Key.new(priv: ENV.fetch("FAUCET_PRIVATE_KEY", DEFAULT_FAUCET_PRIVATE_KEY))
      end

      def faucet_address
        faucet_key.address.to_s
      end

      def faucet_balance(chain = ScaffoldEth::Config.active_chain)
        ScaffoldEth::Client.new(chain).balance(faucet_address)
      end

      # Send `amount_eth` ETH to `to_address`. Returns the tx hash.
      def drip(to_address, amount_eth: DEFAULT_AMOUNT_ETH, chain: ScaffoldEth::Config.active_chain)
        raise NotAvailable, "Faucet is only available on local networks" unless available?(chain)

        amount = validate_amount!(amount_eth) # defense in depth; controller also validates
        addr = ::Eth::Address.new(to_address) # validates / raises on bad address
        client = ScaffoldEth::Client.new(chain)
        amount_wei = (amount * BigDecimal(::Eth::Unit::ETHER.to_i.to_s)).to_i

        client.eth.transfer_and_wait(addr.to_s, amount_wei, sender_key: faucet_key, legacy: true)
      end
    end
  end
end
