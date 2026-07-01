require "test_helper"

module ScaffoldEth
  class FaucetValidateAmountTest < ActiveSupport::TestCase
    test "returns a BigDecimal for a valid positive amount" do
      result = Faucet.validate_amount!(BigDecimal("1.5"))
      assert_instance_of BigDecimal, result
      assert_equal BigDecimal("1.5"), result
    end

    test "accepts the maximum amount" do
      assert_equal Faucet::MAX_AMOUNT_ETH, Faucet.validate_amount!(Faucet::MAX_AMOUNT_ETH)
    end

    test "rejects zero" do
      assert_raises(Faucet::InvalidAmount) { Faucet.validate_amount!(BigDecimal("0")) }
    end

    test "rejects negative amounts" do
      assert_raises(Faucet::InvalidAmount) { Faucet.validate_amount!(BigDecimal("-1")) }
    end

    test "rejects amounts over the cap" do
      over = Faucet::MAX_AMOUNT_ETH + 1
      assert_raises(Faucet::InvalidAmount) { Faucet.validate_amount!(over) }
    end
  end
end
