# frozen_string_literal: true

module Api
  # Exposes the deployed/external contract registry (address + ABI per chain).
  # The JS layer uses this to build viem contract instances — the analogue of
  # SE-2's `deployedContracts.ts` / `useDeployedContractInfo`.
  class ContractsController < BaseController
    def index
      contracts = ScaffoldEth::ContractRegistry.all(chain_id)
      render json: {
        chainId: chain_id,
        contracts: contracts.transform_values(&:as_json)
      }
    end

    def show
      info = ScaffoldEth::ContractRegistry.contract!(params[:name], chain_id)
      render json: info.as_json
    end
  end
end
