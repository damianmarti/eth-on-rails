# frozen_string_literal: true

module Api
  # Serves the scaffold config the JS layer needs to configure wagmi/viem + AppKit.
  class ConfigController < BaseController
    def show
      render json: ScaffoldEth::Config.to_browser_json
    end
  end
end
