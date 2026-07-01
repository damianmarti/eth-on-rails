require "test_helper"

module ScaffoldEth
  class ReaderSerializeTest < ActiveSupport::TestCase
    test "serializes integers as strings to preserve uint256 precision" do
      big = 2**255
      assert_equal big.to_s, Reader.serialize(big)
    end

    test "serialize renders binary strings as hex" do
      bin = "\xDE\xAD".dup.force_encoding(Encoding::ASCII_8BIT)
      assert_equal "0xdead", Reader.serialize(bin)
    end

    test "serialize_typed renders a solidity string as UTF-8 text, not hex" do
      blob = "hello".dup.force_encoding(Encoding::ASCII_8BIT)
      assert_equal "hello", Reader.serialize_typed(blob, "string")
    end

    test "serialize_typed renders bytes as hex" do
      blob = "\x01\x02".dup.force_encoding(Encoding::ASCII_8BIT)
      assert_equal "0x0102", Reader.serialize_typed(blob, "bytes32")
    end

    test "serialize_typed maps uint to a decimal string" do
      assert_equal "42", Reader.serialize_typed(42, "uint256")
    end

    test "serialize_typed handles array types element-wise" do
      assert_equal %w[1 2 3], Reader.serialize_typed([ 1, 2, 3 ], "uint256[]")
    end
  end

  class ReaderReadableGuardTest < ActiveSupport::TestCase
    # Build a Reader without going through #initialize (no client/network needed
    # to exercise the view/pure guard).
    def reader = Reader.allocate

    def info_for(abi)
      ScaffoldEth::ContractRegistry::ContractInfo.new(
        name: "YourContract", address: "0x0000000000000000000000000000000000000001",
        abi: abi, chain_id: 31337
      )
    end

    test "allows view functions" do
      info = info_for([ { "type" => "function", "name" => "greeting", "stateMutability" => "view" } ])
      assert_equal "greeting", reader.send(:ensure_readable!, info, "greeting")["name"]
    end

    test "allows pure functions" do
      info = info_for([ { "type" => "function", "name" => "add", "stateMutability" => "pure" } ])
      assert_nothing_raised { reader.send(:ensure_readable!, info, "add") }
    end

    test "rejects nonpayable (state-changing) functions" do
      info = info_for([ { "type" => "function", "name" => "setGreeting", "stateMutability" => "nonpayable" } ])
      assert_raises(ArgumentError) { reader.send(:ensure_readable!, info, "setGreeting") }
    end

    test "rejects payable functions" do
      info = info_for([ { "type" => "function", "name" => "deposit", "stateMutability" => "payable" } ])
      assert_raises(ArgumentError) { reader.send(:ensure_readable!, info, "deposit") }
    end

    test "raises for an unknown function" do
      info = info_for([ { "type" => "function", "name" => "greeting", "stateMutability" => "view" } ])
      assert_raises(ArgumentError) { reader.send(:ensure_readable!, info, "missing") }
    end
  end
end
