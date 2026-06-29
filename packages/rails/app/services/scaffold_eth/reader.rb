# frozen_string_literal: true

module ScaffoldEth
  # Server-side contract reads via eth.rb. The Ruby analogue of SE-2's
  # `useScaffoldReadContract`, used by the Debug page's read tab, ViewComponents
  # and background jobs.
  class Reader
    def initialize(chain_id = ScaffoldEth::Config.active_chain_id)
      @chain_id = chain_id
      @client = ScaffoldEth::Client.for(chain_id)
    end

    # Read a view/pure function and return the raw decoded value.
    def read(contract_name, function_name, *args)
      info = ScaffoldEth::ContractRegistry.contract!(contract_name, @chain_id)
      @client.call(info.eth_contract, function_name.to_s, *args)
    end

    # Read and JSON-serialize the result using the function's ABI output types
    # (bigints -> strings, string -> text, bytes -> hex).
    def read_json(contract_name, function_name, *args)
      info = ScaffoldEth::ContractRegistry.contract!(contract_name, @chain_id)
      fn = info.functions.find { |f| f["name"] == function_name.to_s }
      value = @client.call(info.eth_contract, function_name.to_s, *args)
      outputs = fn&.dig("outputs") || []

      if outputs.size == 1
        self.class.serialize_typed(value, outputs.first["type"])
      elsif outputs.size > 1 && value.is_a?(Array)
        value.each_with_index.map { |v, i| self.class.serialize_typed(v, outputs[i]["type"]) }
      else
        self.class.serialize(value)
      end
    end

    # Recursively convert decoded ABI values into JSON-safe primitives.
    # Without a type, binary strings are rendered as hex (safe default).
    def self.serialize(value)
      case value
      when Integer
        value.to_s # preserve uint256 precision as a string
      when Array
        value.map { |v| serialize(v) }
      when Hash
        value.transform_values { |v| serialize(v) }
      when String
        value.encoding == Encoding::ASCII_8BIT ? Eth::Util.bin_to_prefixed_hex(value) : value
      else
        value
      end
    end

    # Type-aware serialization for a single decoded value given its ABI type
    # (e.g. "string", "bytes32", "uint256", "address[]"). Solidity `string`
    # decodes to an ASCII-8BIT blob that is actually UTF-8 text, so we must use
    # the type to render it as text rather than hex.
    def self.serialize_typed(value, type)
      if type.to_s.end_with?("]") # array type
        inner = type.to_s.sub(/\[\d*\]\z/, "")
        return Array(value).map { |v| serialize_typed(v, inner) }
      end

      case type.to_s
      when "string"
        value.is_a?(String) ? value.dup.force_encoding(Encoding::UTF_8) : value
      when /\Abytes/
        value.is_a?(String) ? Eth::Util.bin_to_prefixed_hex(value) : value
      when /\A(u?int)/
        value.to_s
      when "address"
        value.to_s
      when "bool"
        value
      else
        serialize(value)
      end
    end
  end
end
