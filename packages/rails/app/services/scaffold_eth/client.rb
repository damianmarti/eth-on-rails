# frozen_string_literal: true

module ScaffoldEth
  # Thin wrapper around Eth::Client (eth.rb) for a given chain. Provides the
  # server-side JSON-RPC access used by reads, the faucet, the block explorer and
  # the event indexer. One memoized client per RPC URL.
  class Client
    class Error < StandardError; end

    attr_reader :chain

    def initialize(chain)
      @chain = chain
    end

    # Client for the configured active/primary chain.
    def self.default
      new(ScaffoldEth::Config.active_chain)
    end

    # Client for a chain key ("hardhat") or chainId (31337).
    def self.for(key_or_id)
      new(ScaffoldEth::Chains.find!(key_or_id))
    end

    def rpc_url
      ScaffoldEth::Config.rpc_url_for(chain)
    end

    # Memoized underlying eth.rb client keyed by RPC URL (process-wide).
    def eth
      @eth ||= (self.class.pool[rpc_url] ||= Eth::Client.create(rpc_url))
    end

    def self.pool
      @pool ||= {}
    end

    # --- Read helpers -----------------------------------------------------

    def chain_id
      eth.chain_id
    end

    def block_number
      rpc("eth_blockNumber").to_i(16)
    end

    # Balance in wei (Integer). eth.rb's get_balance reads the latest block.
    def balance(address)
      eth.get_balance(address)
    end

    def code(address, block = "latest")
      rpc("eth_getCode", address, block)
    end

    def contract?(address)
      c = code(address)
      c.present? && c != "0x"
    end

    def transaction_count(address, block = "latest")
      rpc("eth_getTransactionCount", address, block).to_i(16)
    end

    def gas_price
      rpc("eth_gasPrice").to_i(16)
    end

    # Call a view/pure function on an Eth::Contract, returning decoded value(s).
    def call(contract, function_name, *args)
      eth.call(contract, function_name, *args)
    end

    # --- Raw JSON-RPC -----------------------------------------------------

    # Issue an arbitrary JSON-RPC call by its camelCase method name and return
    # the decoded `result`. Delegates to eth.rb's internal command dispatcher.
    def rpc(method, *params)
      eth.send(:send_command, method, params)["result"]
    rescue IOError => e
      raise Error, e.message
    end

    def healthy?
      block_number
      true
    rescue StandardError
      false
    end
  end
end
