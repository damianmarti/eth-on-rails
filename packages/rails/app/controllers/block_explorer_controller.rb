class BlockExplorerController < ApplicationController
  before_action :require_local_chain
  before_action :build_explorer

  def index
    @latest_number = @explorer.latest_block_number
    @blocks = @explorer.latest_blocks(count: 20)
  end

  def block
    @block = @explorer.block(params[:id], full: true)
    return not_found("Block not found") unless @block

    @transactions = @block[:transactions].map { |h| @explorer.transaction(h.is_a?(Hash) ? h["hash"] : h) }.compact
  end

  def transaction
    @transaction = @explorer.transaction(params[:hash])
    not_found("Transaction not found") unless @transaction
  end

  def address
    @info = @explorer.address_info(params[:address])
  end

  def search
    query = params[:q].to_s.strip
    case @explorer.search_kind(query)
    when :block then redirect_to block_explorer_block_path(query)
    when :tx then redirect_to block_explorer_tx_path(query)
    when :address then redirect_to block_explorer_address_path(query)
    else
      redirect_to block_explorer_path, alert: "Could not interpret '#{query}'"
    end
  end

  private

  def build_explorer
    @explorer = ScaffoldEth::BlockExplorer.new(active_chain.id)
  end

  def require_local_chain
    return if active_chain.local?

    redirect_to root_path, alert: "The built-in block explorer is only available on local networks."
  end

  def not_found(message)
    redirect_to block_explorer_path, alert: message
  end
end
