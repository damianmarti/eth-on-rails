# frozen_string_literal: true

module Api
  # Native-currency USD price. GET /api/price -> { price: 1611.48 } (or null).
  class PriceController < BaseController
    def show
      chain = ScaffoldEth::Chains.find(chain_id) || ScaffoldEth::Config.active_chain
      render json: { price: ScaffoldEth::Price.native_currency(chain), symbol: chain.symbol }
    end
  end
end
