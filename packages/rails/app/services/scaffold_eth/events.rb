# frozen_string_literal: true

module ScaffoldEth
  # Fetches and decodes contract event logs via eth.rb's eth_getLogs.
  # Backs the Debug page's event history and the block-explorer indexer — the
  # Ruby analogue of SE-2's `useScaffoldEventHistory`.
  class Events
    DecodedEvent = Struct.new(
      :name, :args, :address, :block_number, :transaction_hash, :log_index, keyword_init: true
    ) do
      def as_json(*)
        {
          name: name,
          args: args,
          address: address,
          blockNumber: block_number,
          transactionHash: transaction_hash,
          logIndex: log_index
        }
      end
    end

    def initialize(chain_id = ScaffoldEth::Config.active_chain_id)
      @chain_id = chain_id
      @client = ScaffoldEth::Client.for(chain_id)
    end

    # Fetch decoded events for `event_name` emitted by `contract_name`.
    # from_block / to_block accept Integer or "latest"/"earliest".
    def get_events(contract_name, event_name, from_block: 0, to_block: "latest")
      info = ScaffoldEth::ContractRegistry.contract!(contract_name, @chain_id)
      event_abi = info.events.find { |e| e["name"] == event_name.to_s }
      raise ArgumentError, "Unknown event #{event_name} on #{contract_name}" unless event_abi

      # eth.rb camelizes snake_case keys (from_block -> fromBlock) before sending.
      logs = @client.rpc("eth_getLogs", {
        address: info.address,
        topics: [ topic0(event_abi) ],
        from_block: hexify(from_block),
        to_block: hexify(to_block)
      })

      (logs || []).map { |log| decode_log(event_abi, log) }
    end

    # The keccak topic0 for an event ABI fragment.
    def self.topic0(event_abi)
      sig = "#{event_abi['name']}(#{event_abi['inputs'].map { |i| i['type'] }.join(',')})"
      Eth::Util.prefix_hex(Eth::Util.bin_to_hex(Eth::Util.keccak256(sig)))
    end

    private

    def topic0(event_abi)
      self.class.topic0(event_abi)
    end

    def hexify(block)
      return block if block.is_a?(String)

      Eth::Util.prefix_hex(block.to_i.to_s(16))
    end

    def decode_log(event_abi, log)
      inputs = event_abi["inputs"]
      indexed = inputs.select { |i| i["indexed"] }
      non_indexed = inputs.reject { |i| i["indexed"] }

      args = {}

      # Indexed args come from topics[1..]; topics[0] is the event signature.
      topics = log["topics"][1..] || []
      indexed.each_with_index do |input, i|
        args[input["name"]] = decode_topic(input["type"], topics[i])
      end

      # Non-indexed args are ABI-decoded from the data blob.
      unless non_indexed.empty?
        types = non_indexed.map { |i| i["type"] }
        values = Eth::Abi.decode(types, log["data"])
        non_indexed.each_with_index do |input, i|
          args[input["name"]] = ScaffoldEth::Reader.serialize_typed(values[i], input["type"])
        end
      end

      DecodedEvent.new(
        name: event_abi["name"],
        args: args,
        address: log["address"],
        block_number: log["blockNumber"]&.to_i(16),
        transaction_hash: log["transactionHash"],
        log_index: log["logIndex"]&.to_i(16)
      )
    end

    # Decode a single 32-byte indexed topic for value types. Dynamic types
    # (string/bytes) are only stored as a hash when indexed, so we surface that.
    def decode_topic(type, topic)
      return nil if topic.nil?

      if type == "address"
        Eth::Util.prefix_hex(topic[-40..])
      elsif type.start_with?("uint") || type.start_with?("int")
        topic.to_i(16).to_s
      elsif type == "bool"
        topic.to_i(16) == 1
      elsif type.start_with?("bytes")
        topic
      else
        # string/bytes/tuple/array indexed -> only the keccak hash is available
        topic
      end
    end
  end
end
