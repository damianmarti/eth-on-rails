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
      from_block, to_block = resolve_range(
        parse_block(params[:from_block], default: "earliest"),
        parse_block(params[:to_block], default: "latest")
      )

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

    # Resolve symbolic bounds ("earliest"/"latest") to concrete block numbers so
    # the range cap always applies — otherwise "from_block=0" with an omitted
    # (latest) to_block would scan block 0..head unbounded. Returns [from, to].
    def resolve_range(from_block, to_block)
      from = resolve_bound(from_block)
      to = resolve_bound(to_block)
      raise ArgumentError, "from_block must be <= to_block" if from > to
      raise ArgumentError, "Block range exceeds #{MAX_BLOCK_RANGE}" if to - from > MAX_BLOCK_RANGE

      [ from, to ]
    end

    def resolve_bound(bound)
      case bound
      when "earliest" then 0
      when "latest" then latest_block
      else bound # already a non-negative Integer
      end
    end

    def latest_block
      @latest_block ||= ScaffoldEth::Client.for(chain_id).block_number
    end
  end
end
