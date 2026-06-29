# frozen_string_literal: true

module Api
  # ENS forward/reverse resolution. GET /api/ens?address=0x.. or ?name=foo.eth
  class EnsController < BaseController
    def show
      if params[:name].present?
        render json: { name: params[:name], address: ScaffoldEth::Ens.resolve(params[:name]) }
      elsif params[:address].present?
        name = ScaffoldEth::Ens.reverse(params[:address])
        render json: {
          address: params[:address],
          name: name,
          avatar: name && ScaffoldEth::Ens.avatar(name)
        }
      else
        render json: { error: "provide ?name= or ?address=" }, status: :bad_request
      end
    end
  end
end
