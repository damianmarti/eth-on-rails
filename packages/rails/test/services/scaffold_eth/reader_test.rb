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
      assert_equal %w[1 2 3], Reader.serialize_typed([1, 2, 3], "uint256[]")
    end
  end
end
