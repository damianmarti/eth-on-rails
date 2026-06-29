# frozen_string_literal: true

module Api
  # Latest blocks as JSON, used by the explorer's live "block-stream" controller
  # to append new blocks without a full reload.
  class BlocksController < BaseController
    def index
      explorer = ScaffoldEth::BlockExplorer.new(chain_id)
      since = params[:since].presence&.to_i
      blocks = explorer.latest_blocks(count: 20)
      blocks = blocks.select { |b| b[:number] > since } if since

      render json: {
        latest: explorer.latest_block_number,
        blocks: blocks.map { |b| b.slice(:number, :timestamp, :tx_count, :gas_used, :miner) }
      }
    end
  end
end
