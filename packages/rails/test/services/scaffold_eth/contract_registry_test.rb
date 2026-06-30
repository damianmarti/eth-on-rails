require "test_helper"

module ScaffoldEth
  class ContractRegistrySelectorTest < ActiveSupport::TestCase
    # Only meaningful when the sample contract is deployed locally.
    def setup
      skip "YourContract not deployed" unless ContractRegistry.contract("YourContract", 31337)
    end

    test "computes the canonical 4-byte selector for setGreeting" do
      selectors = ContractRegistry.function_selectors(31337)
      entry = selectors["0xa4136862"]
      assert entry, "expected setGreeting selector 0xa4136862"
      assert_equal "setGreeting", entry[:name]
    end

    test "maps the totalCounter getter selector" do
      selectors = ContractRegistry.function_selectors(31337)
      assert selectors.values.any? { |v| v[:name] == "totalCounter" }
    end
  end
end
