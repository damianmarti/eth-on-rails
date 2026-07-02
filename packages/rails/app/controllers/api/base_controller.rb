# frozen_string_literal: true

module Api
  # Base for the JSON API the Stimulus/JS layer calls. These endpoints expose the
  # eth.rb server layer (registry, reads, events, ENS, faucet) to the browser.
  # Writes are intentionally NOT exposed here — they are signed by the wallet.
  class BaseController < ActionController::Base
    # Read endpoints are all GET (not CSRF-checked). State-changing endpoints
    # (e.g. the faucet drip) must keep forgery protection — they opt in via
    # `protect_from_forgery with: :exception`, and the JS layer sends the
    # X-CSRF-Token header. Do NOT skip forgery protection app-wide here.

    rescue_from StandardError, with: :render_error
    rescue_from ArgumentError, with: :render_bad_request
    rescue_from ActionController::InvalidAuthenticityToken, with: :render_forbidden

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

    def render_forbidden(_error)
      render json: { error: "Invalid or missing CSRF token" }, status: :forbidden
    end
  end
end
