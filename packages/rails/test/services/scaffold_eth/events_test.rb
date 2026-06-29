require "test_helper"

module ScaffoldEth
  class EventsTopicTest < ActiveSupport::TestCase
    test "computes the correct keccak topic0 for an event signature" do
      abi = {
        "name" => "Transfer",
        "inputs" => [
          { "type" => "address", "indexed" => true },
          { "type" => "address", "indexed" => true },
          { "type" => "uint256", "indexed" => false }
        ]
      }
      # Canonical ERC-20 Transfer(address,address,uint256) topic.
      assert_equal(
        "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
        Events.topic0(abi)
      )
    end
  end
end
