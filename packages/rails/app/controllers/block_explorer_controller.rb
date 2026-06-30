class BlockExplorerController < ApplicationController
  before_action :require_local_chain
  before_action :build_explorer

  def index
    @latest_number = @explorer.latest_block_number
    @page = params[:page].to_i
    @page = 1 if @page < 1
    result = @explorer.latest_transactions(page: @page, per_page: 20)
    @transactions = result[:transactions]
    @page = result[:page]
    @pages = result[:pages]
    @total = result[:total]
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
    @transactions = @explorer.transactions_for(params[:address])
    @code = @info[:is_contract] ? @explorer.code(params[:address]) : nil
    @tab = params[:tab].presence || "transactions"
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
