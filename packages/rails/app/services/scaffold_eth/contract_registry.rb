# frozen_string_literal: true

module ScaffoldEth
  # Loads the deployed + external contract artifacts (the JSON emitted by the
  # Hardhat/Foundry generators) and builds Eth::Contract instances on demand.
  #
  # This is the source of truth shared with the JS bundle and the Ruby analogue
  # of SE-2's `useDeployedContractInfo` / `deployedContracts.ts`.
  #
  # "Hot reload": the artifact is re-read whenever the file mtime changes, so a
  # redeploy is picked up without restarting the server.
  module ContractRegistry
    DEPLOYED_PATH = Rails.root.join("config", "contracts", "deployed_contracts.json")
    EXTERNAL_PATH = Rails.root.join("config", "contracts", "external_contracts.json")

    ContractInfo = Struct.new(:name, :address, :abi, :chain_id, keyword_init: true) do
      # Memoized Eth::Contract for eth.rb calls.
      def eth_contract
        @eth_contract ||= Eth::Contract.from_abi(name: contract_class_name, address: address, abi: abi)
      end

      # ABI entries of a given type ("function", "event").
      def abi_of_type(type)
        abi.select { |e| e["type"] == type }
      end

      def functions = abi_of_type("function")
      def events = abi_of_type("event")

      # Read-only (view/pure) functions — what server-side reads can call.
      def read_functions
        functions.select { |f| %w[view pure].include?(f["stateMutability"]) }
      end

      # State-changing functions — must be signed by the browser wallet.
      def write_functions
        functions.reject { |f| %w[view pure].include?(f["stateMutability"]) }
      end

      def as_json(*)
        { name: name, address: address, abi: abi, chainId: chain_id }
      end

      private

      # Eth::Contract requires a constant-style name.
      def contract_class_name
        name.to_s.gsub(/[^a-zA-Z0-9]/, "_").camelize
      end
    end

    class << self
      # All contracts for a chain: { "YourContract" => ContractInfo }.
      def all(chain_id = ScaffoldEth::Config.active_chain_id)
        cache.fetch(chain_id.to_i) { build_for(chain_id.to_i) }
      end

      def contract(name, chain_id = ScaffoldEth::Config.active_chain_id)
        all(chain_id)[name.to_s]
      end

      def contract!(name, chain_id = ScaffoldEth::Config.active_chain_id)
        contract(name, chain_id) ||
          raise(ArgumentError, "Contract #{name.inspect} not found on chain #{chain_id}")
      end

      def names(chain_id = ScaffoldEth::Config.active_chain_id)
        all(chain_id).keys
      end

      def reload!
        @cache = nil
        @signature = nil
      end

      private

      # mtime-based cache so redeploys are picked up without a restart.
      def cache
        sig = current_signature
        if @signature != sig
          @cache = {}
          @signature = sig
        end
        @cache ||= {}
      end

      def current_signature
        [DEPLOYED_PATH, EXTERNAL_PATH].map { |p| File.exist?(p) ? File.mtime(p).to_f : 0 }
      end

      def build_for(chain_id)
        merged = deep_merge(read_json(DEPLOYED_PATH), strip_examples(read_json(EXTERNAL_PATH)))
        chain_data = merged[chain_id.to_s] || {}
        chain_data.each_with_object({}) do |(name, entry), memo|
          next unless entry.is_a?(Hash) && entry["address"] && entry["abi"]

          memo[name] = ContractInfo.new(
            name: name, address: entry["address"], abi: entry["abi"], chain_id: chain_id
          )
        end
      end

      def read_json(path)
        return {} unless File.exist?(path)

        JSON.parse(File.read(path)).tap { |h| return {} unless h.is_a?(Hash) }
      rescue JSON::ParserError
        {}
      end

      # Drop the underscore-prefixed documentation keys from external_contracts.json.
      def strip_examples(hash)
        hash.reject { |k, _| k.to_s.start_with?("_") }
      end

      def deep_merge(a, b)
        a.merge(b) do |_key, av, bv|
          av.is_a?(Hash) && bv.is_a?(Hash) ? deep_merge(av, bv) : bv
        end
      end
    end
  end
end
