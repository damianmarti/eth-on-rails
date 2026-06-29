# frozen_string_literal: true

module ScaffoldEth
  # Loads config/scaffold_eth.yml (the `scaffold.config.ts` analogue) and exposes
  # it to both the Ruby server layer and the browser (via #to_browser_json).
  module Config
    CONFIG_PATH = Rails.root.join("config", "scaffold_eth.yml")

    class << self
      def data
        @data ||= load_config
      end

      def reload!
        @data = nil
        data
      end

      # Config keys of the target networks, first = primary.
      def target_network_keys
        Array(data["target_networks"]).presence || %w[hardhat]
      end

      # ScaffoldEth::Chains::Chain objects for the target networks.
      def target_networks
        target_network_keys.map { |k| ScaffoldEth::Chains.find!(k) }
      end

      # The primary network used for server-side reads / faucet / explorer.
      def active_chain
        if data["active_chain_id"]
          ScaffoldEth::Chains.find!(data["active_chain_id"])
        else
          target_networks.first
        end
      end

      def active_chain_id
        active_chain.id
      end

      def polling_interval = data.fetch("polling_interval", 30_000)
      def only_local_burner_wallet? = data.fetch("only_local_burner_wallet", true)
      def wallet_connect_project_id = data["wallet_connect_project_id"]
      def alchemy_api_key = data["alchemy_api_key"]
      def rpc_overrides = data.fetch("rpc_overrides", {}) || {}

      # RPC URL for a chain, honoring rpc_overrides from the yml.
      def rpc_url_for(chain)
        rpc_overrides[chain.key] || rpc_overrides[chain.id.to_s] || chain.rpc
      end

      # Everything the browser JS layer needs to configure wagmi/viem + AppKit.
      def to_browser_json
        {
          targetNetworks: target_networks.map(&:as_json),
          activeChainId: active_chain_id,
          pollingInterval: polling_interval,
          onlyLocalBurnerWallet: only_local_burner_wallet?,
          walletConnectProjectId: wallet_connect_project_id
        }
      end

      private

      def load_config
        erb = ERB.new(File.read(CONFIG_PATH)).result
        all = YAML.safe_load(erb, aliases: true) || {}
        env = (defined?(Rails) && Rails.env) || "development"
        (all[env] || all["default"] || {})
      end
    end
  end
end
