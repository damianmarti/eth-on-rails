# frozen_string_literal: true

module Api
  # Server-side contract read (eth.rb). GET /api/read?contract=Foo&function=bar&args[]=...
  class ReadsController < BaseController
    def show
      contract = params.require(:contract)
      function = params.require(:function)
      args = Array(params[:args]).map { |a| coerce_arg(a) }

      value = ScaffoldEth::Reader.new(chain_id).read_json(contract, function, *args)
      render json: { contract: contract, function: function, value: value }
    end

    private

    # Args arrive as strings; pass through (eth.rb encodes per ABI type).
    # Numeric strings stay as strings to preserve uint256 precision.
    def coerce_arg(arg)
      arg
    end
  end
end
