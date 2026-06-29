# frozen_string_literal: true

module Api
  # Decoded event history (eth.rb getLogs). GET /api/events?contract=Foo&event=Bar
  class EventsController < BaseController
    def index
      contract = params.require(:contract)
      event = params.require(:event)
      from_block = params[:from_block].presence || 0
      to_block = params[:to_block].presence || "latest"
      from_block = from_block.to_i unless from_block == "latest" || from_block == "earliest"

      events = ScaffoldEth::Events.new(chain_id)
        .get_events(contract, event, from_block: from_block, to_block: to_block)

      render json: { contract: contract, event: event, events: events.map(&:as_json) }
    end
  end
end
