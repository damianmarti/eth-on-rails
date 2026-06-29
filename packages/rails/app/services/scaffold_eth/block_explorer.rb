# frozen_string_literal: true

module ScaffoldEth
  # Read-only block explorer backed by eth.rb JSON-RPC. Powers the local
  # /blockexplorer pages (block list, block, transaction, address). Mirrors
  # SE-2's local block explorer. Values are decoded into plain hashes for views.
  class BlockExplorer
    def initialize(chain_id = ScaffoldEth::Config.active_chain_id)
      @chain_id = chain_id
      @client = ScaffoldEth::Client.for(chain_id)
    end

    def latest_block_number
      @client.block_number
    end

    # The most recent `count` blocks (newest first), with tx counts.
    def latest_blocks(count: 25)
      tip = latest_block_number
      first = [tip - count + 1, 0].max
      (first..tip).map { |n| block(n) }.compact.reverse
    end

    # A block by number (Integer) or hash (0x…). full: include tx objects.
    def block(id, full: false)
      raw =
        if id.to_s.start_with?("0x") && id.to_s.length > 12
          @client.rpc("eth_getBlockByHash", id, full)
        else
          @client.rpc("eth_getBlockByNumber", hex(id), full)
        end
      raw && format_block(raw)
    end

    def transaction(hash)
      raw = @client.rpc("eth_getTransactionByHash", hash)
      return nil unless raw

      receipt = @client.rpc("eth_getTransactionReceipt", hash)
      format_transaction(raw, receipt)
    end

    def receipt(hash)
      @client.rpc("eth_getTransactionReceipt", hash)
    end

    # Summary for an address: balance, nonce, contract?/code size.
    def address_info(address)
      code = @client.code(address)
      {
        address: address,
        balance: @client.balance(address),
        nonce: @client.transaction_count(address),
        is_contract: code.present? && code != "0x",
        code_size: code.present? && code != "0x" ? (code.length - 2) / 2 : 0
      }
    end

    # Naive search: routes a query to the right page type.
    def search_kind(query)
      q = query.to_s.strip
      return :block if q.match?(/\A\d+\z/)
      return :tx if q.match?(/\A0x[0-9a-fA-F]{64}\z/)
      return :address if q.match?(/\A0x[0-9a-fA-F]{40}\z/)
      return :block if q.match?(/\A0x[0-9a-fA-F]{64}\z/) # block hash handled by tx check above

      :unknown
    end

    private

    def hex(n)
      return n if n.is_a?(String) && n.start_with?("0x")

      Eth::Util.prefix_hex(n.to_i.to_s(16))
    end

    def to_i(hex_str)
      hex_str.nil? ? nil : hex_str.to_i(16)
    end

    def format_block(raw)
      {
        number: to_i(raw["number"]),
        hash: raw["hash"],
        parent_hash: raw["parentHash"],
        timestamp: to_i(raw["timestamp"]),
        miner: raw["miner"],
        gas_used: to_i(raw["gasUsed"]),
        gas_limit: to_i(raw["gasLimit"]),
        base_fee_per_gas: to_i(raw["baseFeePerGas"]),
        size: to_i(raw["size"]),
        tx_count: (raw["transactions"] || []).size,
        transactions: raw["transactions"] || []
      }
    end

    def format_transaction(raw, receipt)
      {
        hash: raw["hash"],
        block_number: to_i(raw["blockNumber"]),
        from: raw["from"],
        to: raw["to"],
        value: to_i(raw["value"]),
        nonce: to_i(raw["nonce"]),
        gas: to_i(raw["gas"]),
        gas_price: to_i(raw["gasPrice"]),
        input: raw["input"],
        status: receipt && to_i(receipt["status"]),
        gas_used: receipt && to_i(receipt["gasUsed"]),
        contract_address: receipt && receipt["contractAddress"],
        logs: receipt ? (receipt["logs"] || []) : []
      }
    end
  end
end
