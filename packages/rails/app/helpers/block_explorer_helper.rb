module BlockExplorerHelper
  # Format a wei Integer as a trimmed ETH string.
  def format_eth(wei, decimals: 6)
    return "0" if wei.nil? || wei.zero?

    eth = BigDecimal(wei.to_s) / BigDecimal(Eth::Unit::ETHER.to_i.to_s)
    eth.round(decimals).to_s("F")
  end

  def format_gwei(wei)
    return "0" if wei.nil? || wei.zero?

    (BigDecimal(wei.to_s) / BigDecimal(Eth::Unit::GWEI.to_i.to_s)).round(4).to_s("F")
  end

  def block_time_ago(timestamp)
    return "" if timestamp.nil?

    "#{time_ago_in_words(Time.at(timestamp))} ago"
  end

  # Map an address back to a deployed contract name, if any (case-insensitive).
  def name_for_address(address)
    ScaffoldEth::ContractRegistry.all.each do |name, info|
      return name if info.address.to_s.downcase == address.to_s.downcase
    end
    nil
  rescue StandardError
    nil
  end

  def tx_status_badge(status)
    if status == 1
      tag.span("Success", class: "badge badge-success badge-sm")
    elsif status == 0
      tag.span("Failed", class: "badge badge-error badge-sm")
    else
      tag.span("Pending", class: "badge badge-ghost badge-sm")
    end
  end
end
