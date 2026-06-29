require "test_helper"

module ScaffoldEth
  class ChainsTest < ActiveSupport::TestCase
    test "loads the local hardhat chain with the right id" do
      chain = Chains.find!("hardhat")
      assert_equal 31337, chain.id
      assert chain.local?
    end

    test "finds a chain by numeric id" do
      assert_equal "mainnet", Chains.find(1).key
    end

    test "interpolates the alchemy key into rpc urls" do
      assert_not_includes Chains.find!("sepolia").rpc, "%{alchemy}"
    end

    test "as_json exposes the fields the browser needs" do
      json = Chains.find!("hardhat").as_json
      assert_equal 31337, json[:id]
      assert_equal "http://127.0.0.1:8545", json[:rpcUrl]
      assert json[:local]
    end
  end
end
