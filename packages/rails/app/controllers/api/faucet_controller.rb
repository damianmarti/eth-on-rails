# frozen_string_literal: true

module Api
  # Local faucet. POST /api/faucet { address, amount } -> drips ETH via eth.rb.
  class FaucetController < BaseController
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
      amount = (params[:amount].presence || ScaffoldEth::Faucet::DEFAULT_AMOUNT_ETH).to_f
      chain = ScaffoldEth::Chains.find!(chain_id)

      tx_hash = ScaffoldEth::Faucet.drip(address, amount_eth: amount, chain: chain)
      render json: { ok: true, txHash: tx_hash, address: address, amount: amount }
    rescue ScaffoldEth::Faucet::NotAvailable => e
      render json: { ok: false, error: e.message }, status: :forbidden
    end
  end
end
