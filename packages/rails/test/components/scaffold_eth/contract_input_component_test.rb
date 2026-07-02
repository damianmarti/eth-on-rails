require "test_helper"

module ScaffoldEth
  class ContractInputComponentTest < ViewComponent::TestCase
    test "emits tuple component metadata as JSON for tuple inputs" do
      abi_input = {
        "type" => "tuple", "name" => "payment",
        "components" => [
          { "name" => "amount", "type" => "uint256" },
          { "name" => "ok", "type" => "bool" }
        ]
      }
      result = render_inline(ContractInputComponent.new(abi_input: abi_input, index: 0, function_name: "pay"))

      input = result.at_css("[data-scaffold-arg-input]")
      assert_equal "tuple", input["data-scaffold-arg-type"]
      components = JSON.parse(input["data-scaffold-arg-components"])
      assert_equal %w[amount ok], components.map { |c| c["name"] }
      assert_equal "uint256", components.first["type"]
    end

    test "omits component metadata for plain (non-tuple) inputs" do
      abi_input = { "type" => "string", "name" => "greeting" }
      result = render_inline(ContractInputComponent.new(abi_input: abi_input, index: 1, function_name: "setGreeting"))

      input = result.at_css("[data-scaffold-arg-input]")
      assert_nil input["data-scaffold-arg-components"]
    end
  end
end
