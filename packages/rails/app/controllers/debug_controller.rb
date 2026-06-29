class DebugController < ApplicationController
  # Auto-generated contract interaction UI (SE-2's "Debug Contracts").
  def index
    @contract_names = deployed_contract_names
    @selected = params[:contract].presence || @contract_names.first
    @contract = ScaffoldEth::ContractRegistry.contract(@selected) if @selected
  end

  def show
    @contract_names = deployed_contract_names
    @selected = params[:contract]
    @contract = ScaffoldEth::ContractRegistry.contract(@selected)
    return redirect_to(debug_path) unless @contract

    render :index
  end
end
