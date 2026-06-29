class FaucetController < ApplicationController
  before_action :require_local_chain

  def index
    @faucet_address = ScaffoldEth::Faucet.faucet_address
    @faucet_balance = ScaffoldEth::Faucet.faucet_balance
  rescue StandardError => e
    @error = e.message
  end

  private

  def require_local_chain
    return if active_chain.local?

    redirect_to root_path, alert: "The faucet is only available on local networks."
  end
end
