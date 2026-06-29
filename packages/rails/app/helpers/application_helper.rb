module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when "notice", "success" then "alert-success"
    when "alert", "error" then "alert-error"
    when "warning" then "alert-warning"
    else "alert-info"
    end
  end

  # Navbar link with active-state styling (DaisyUI).
  def nav_link(label, path)
    active = current_page?(path)
    classes = [
      "btn btn-sm btn-ghost rounded-full font-normal",
      ("bg-secondary shadow-md" if active)
    ].compact.join(" ")
    link_to label, path, class: classes
  end

  # Short 0x1234…abcd address rendering.
  def short_address(address)
    return "" if address.blank?

    a = address.to_s
    "#{a[0, 6]}…#{a[-4, 4]}"
  end

  # Block explorer URL for a tx/address on the active chain (local -> internal explorer).
  def explorer_tx_url(hash, chain: active_chain)
    if chain.local?
      block_explorer_tx_path(hash)
    elsif chain.block_explorer.present?
      "#{chain.block_explorer}/tx/#{hash}"
    end
  end

  def explorer_address_url(address, chain: active_chain)
    if chain.local?
      block_explorer_address_path(address)
    elsif chain.block_explorer.present?
      "#{chain.block_explorer}/address/#{address}"
    end
  end
end
