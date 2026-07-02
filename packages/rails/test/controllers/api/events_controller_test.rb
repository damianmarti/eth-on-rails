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

    test "caps an unbounded from_block=0 with omitted to_block (resolves latest)" do
      # Common UI path: from_block=0, no to_block. "latest" must resolve to the
      # current block so the range cap applies instead of scanning 0..head.
      fake_client = Struct.new(:block_number).new(Api::EventsController::MAX_BLOCK_RANGE + 5_000)
      with_stubbed_client(fake_client) do
        get "/api/events", params: { contract: "YourContract", event: "GreetingChange", from_block: 0 }
        assert_response :bad_request
      end
    end

    private

    # Temporarily replace ScaffoldEth::Client.for with a stub that returns
    # fake_client, restoring the original afterward.
    def with_stubbed_client(fake_client)
      original = ScaffoldEth::Client.method(:for)
      ScaffoldEth::Client.define_singleton_method(:for) { |*| fake_client }
      yield
    ensure
      ScaffoldEth::Client.define_singleton_method(:for, original)
    end
  end
end
