class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :scaffold_config, :active_chain, :target_networks, :deployed_contract_names

  private

  def scaffold_config
    ScaffoldEth::Config
  end

  def active_chain
    ScaffoldEth::Config.active_chain
  end

  def target_networks
    ScaffoldEth::Config.target_networks
  end

  def deployed_contract_names
    ScaffoldEth::ContractRegistry.names
  rescue StandardError
    []
  end
end
