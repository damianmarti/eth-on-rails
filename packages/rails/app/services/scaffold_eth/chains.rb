# frozen_string_literal: true

module ScaffoldEth
  # Registry of known chains, loaded from config/scaffold_eth/chains.yml.
  # The Ruby analogue of viem's chain definitions: provides id, RPC URLs,
  # native currency, block explorer and a UI color for each supported network.
  module Chains
    Chain = Struct.new(
      :key, :id, :name, :network, :rpc, :ws, :currency,
      :block_explorer, :color, :testnet, :local,
      keyword_init: true
    ) do
      def local? = !!local
      def testnet? = !!testnet
      def symbol = currency&.fetch("symbol", "ETH")
      def decimals = currency&.fetch("decimals", 18)

      # Serializable form sent to the browser / used by viem chain config.
      def as_json(*)
        {
          key: key, id: id, name: name, network: network,
          rpcUrl: rpc, wsUrl: ws,
          nativeCurrency: currency,
          blockExplorer: block_explorer.to_s.empty? ? nil : block_explorer,
          color: color, testnet: testnet?, local: local?
        }
      end
    end

    CONFIG_PATH = Rails.root.join("config", "scaffold_eth", "chains.yml")

    class << self
      # Returns { "hardhat" => Chain, ... } with the Alchemy key interpolated.
      def all
        @all ||= load_chains
      end

      def reload!
        @all = nil
        all
      end

      # Look up by config key ("hardhat") or by numeric chainId (31337).
      def find(key_or_id)
        return all[key_or_id.to_s] if all.key?(key_or_id.to_s)

        all.values.find { |c| c.id == key_or_id.to_i }
      end

      def find!(key_or_id)
        find(key_or_id) || raise(ArgumentError, "Unknown chain: #{key_or_id.inspect}")
      end

      private

      def load_chains
        raw = YAML.safe_load(File.read(CONFIG_PATH), aliases: true) || {}
        alchemy = ScaffoldEth::Config.alchemy_api_key
        raw.each_with_object({}) do |(key, attrs), memo|
          memo[key] = Chain.new(
            key: key,
            id: attrs["id"],
            name: attrs["name"],
            network: attrs["network"],
            rpc: interpolate(attrs["rpc"], alchemy),
            ws: interpolate(attrs["ws"], alchemy),
            currency: attrs["currency"],
            block_explorer: attrs["block_explorer"],
            color: attrs["color"],
            testnet: attrs["testnet"],
            local: attrs["local"]
          )
        end
      end

      def interpolate(url, alchemy)
        return url if url.nil?

        url.gsub("%{alchemy}", alchemy.to_s)
      end
    end
  end
end
