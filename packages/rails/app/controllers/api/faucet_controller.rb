# frozen_string_literal: true

module Api
  # Local faucet. POST /api/faucet { address, amount } -> drips ETH via eth.rb.
  class FaucetController < BaseController
    # This is the only state-changing API endpoint and it signs a transaction
    # with the funded dev key, so it must verify CSRF and be rate limited.
    protect_from_forgery with: :exception, only: :create
    rate_limit to: 10, within: 1.minute, only: :create

    def show
      chain = ScaffoldEth::Chains.find!(chain_id)
      render json: {
        available: ScaffoldEth::Faucet.available?(chain),
        faucetAddress: ScaffoldEth::Faucet.faucet_address,
        faucetBalance: (ScaffoldEth::Faucet.faucet_balance(chain).to_s rescue nil)
      }
    end

    def create
      address = params.require(:address)
      amount = parse_amount(params[:amount])
      chain = ScaffoldEth::Chains.find!(chain_id)

      tx_hash = ScaffoldEth::Faucet.drip(address, amount_eth: amount, chain: chain)
      render json: { ok: true, txHash: tx_hash, address: address, amount: amount.to_s("F") }
    rescue ScaffoldEth::Faucet::NotAvailable => e
      render json: { ok: false, error: e.message }, status: :forbidden
    rescue ScaffoldEth::Faucet::InvalidAmount, ArgumentError => e
      render json: { ok: false, error: e.message }, status: :unprocessable_entity
    end

    private

    # Strictly parse the requested amount into a finite, positive, capped
    # BigDecimal. Rejects blanks, non-numeric junk, zero/negative and oversized
    # values before anything is signed.
    def parse_amount(raw)
      return ScaffoldEth::Faucet::DEFAULT_AMOUNT_ETH if raw.blank?

      str = raw.to_s.strip
      raise ScaffoldEth::Faucet::InvalidAmount, "Amount is not a valid number" unless
        str.match?(/\A\d+(\.\d+)?\z/)

      ScaffoldEth::Faucet.validate_amount!(BigDecimal(str))
    end
  end
end
