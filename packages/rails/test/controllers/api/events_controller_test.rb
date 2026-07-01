require "test_helper"

module Api
  class EventsControllerTest < ActionDispatch::IntegrationTest
    # These requests are rejected by block-range validation before any getLogs
    # call, so they need no live chain.

    test "rejects a non-numeric from_block with 400" do
      get "/api/events", params: { contract: "YourContract", event: "GreetingChange", from_block: "abc" }
      assert_response :bad_request
    end

    test "rejects a non-numeric to_block with 400" do
      get "/api/events", params: { contract: "YourContract", event: "GreetingChange", to_block: "soon" }
      assert_response :bad_request
    end

    test "rejects an over-wide block range with 400" do
      over = Api::EventsController::MAX_BLOCK_RANGE + 1
      get "/api/events", params: { contract: "YourContract", event: "GreetingChange", from_block: 0, to_block: over }
      assert_response :bad_request
    end

    test "rejects from_block greater than to_block with 400" do
      get "/api/events", params: { contract: "YourContract", event: "GreetingChange", from_block: 100, to_block: 50 }
      assert_response :bad_request
    end
  end
end
