# frozen_string_literal: true

module Api
  # Decoded event history (eth.rb getLogs). GET /api/events?contract=Foo&event=Bar
  class EventsController < BaseController
    # Cap how wide a numeric block range a single request may scan, to avoid
    # unbounded getLogs sweeps against the RPC node.
    MAX_BLOCK_RANGE = 100_000

    def index
      contract = params.require(:contract)
      event = params.require(:event)
      from_block = parse_block(params[:from_block], default: "earliest")
      to_block = parse_block(params[:to_block], default: "latest")
      check_range!(from_block, to_block)

      events = ScaffoldEth::Events.new(chain_id)
        .get_events(contract, event, from_block: from_block, to_block: to_block)

      render json: { contract: contract, event: event, events: events.map(&:as_json) }
    end

    private

    # Accept only "latest"/"earliest" or a non-negative integer; reject anything
    # else (Events#hexify passes unknown strings straight to the RPC).
    def parse_block(raw, default:)
      value = raw.presence
      return default if value.nil?
      return value if %w[latest earliest].include?(value)
      raise ArgumentError, "Invalid block: #{value.inspect}" unless value.to_s.match?(/\A\d+\z/)

      value.to_i
    end

    def check_range!(from_block, to_block)
      return unless from_block.is_a?(Integer) && to_block.is_a?(Integer)
      raise ArgumentError, "from_block must be <= to_block" if from_block > to_block
      raise ArgumentError, "Block range exceeds #{MAX_BLOCK_RANGE}" if to_block - from_block > MAX_BLOCK_RANGE
    end
  end
end
