# frozen_string_literal: true

module Api
  # Base for the JSON API the Stimulus/JS layer calls. These endpoints expose the
  # eth.rb server layer (registry, reads, events, ENS, faucet) to the browser.
  # Writes are intentionally NOT exposed here — they are signed by the wallet.
  class BaseController < ActionController::Base
    skip_forgery_protection

    rescue_from StandardError, with: :render_error
    rescue_from ArgumentError, with: :render_bad_request

    private

    # Chain id from params, falling back to the configured active chain.
    def chain_id
      params[:chain_id].presence&.to_i || ScaffoldEth::Config.active_chain_id
    end

    def render_error(error)
      Rails.logger.error("[api] #{error.class}: #{error.message}")
      render json: { error: error.message }, status: :internal_server_error
    end

    def render_bad_request(error)
      render json: { error: error.message }, status: :bad_request
    end
  end
end
