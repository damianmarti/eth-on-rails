# frozen_string_literal: true

module Api
  # Latest blocks as JSON, used by the explorer's live "block-stream" controller
  # to append new blocks without a full reload.
  class BlocksController < BaseController
    def index
      explorer = ScaffoldEth::BlockExplorer.new(chain_id)
      render json: { latest: explorer.latest_block_number }
    end
  end
end
