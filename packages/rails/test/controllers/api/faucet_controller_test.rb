require "test_helper"

module Api
  class FaucetControllerTest < ActionDispatch::IntegrationTest
    VALID_ADDRESS = "0x0000000000000000000000000000000000000001".freeze

    # Amount validation happens before the drip is signed, so these requests
    # need no live chain.

    test "rejects a negative amount with 422" do
      post "/api/faucet", params: { address: VALID_ADDRESS, amount: -1 }, as: :json
      assert_response :unprocessable_entity
    end

    test "rejects a zero amount with 422" do
      post "/api/faucet", params: { address: VALID_ADDRESS, amount: 0 }, as: :json
      assert_response :unprocessable_entity
    end

    test "rejects an amount over the cap with 422" do
      over = (ScaffoldEth::Faucet::MAX_AMOUNT_ETH + 1).to_s("F")
      post "/api/faucet", params: { address: VALID_ADDRESS, amount: over }, as: :json
      assert_response :unprocessable_entity
    end

    test "rejects a non-numeric amount with 422" do
      post "/api/faucet", params: { address: VALID_ADDRESS, amount: "abc" }, as: :json
      assert_response :unprocessable_entity
    end

    test "rejects a POST without a CSRF token with 403" do
      with_forgery_protection do
        post "/api/faucet", params: { address: VALID_ADDRESS, amount: 1 }, as: :json
        assert_response :forbidden
      end
    end

    private

    # CSRF protection is disabled in the test environment by default; turn it on
    # for the duration of the block so the forgery check actually runs.
    def with_forgery_protection
      original = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      yield
    ensure
      ActionController::Base.allow_forgery_protection = original
    end
  end
end
