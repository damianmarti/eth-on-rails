module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when "notice", "success" then "alert-success"
    when "alert", "error" then "alert-error"
    when "warning" then "alert-warning"
    else "alert-info"
    end
  end

  # Full-height navbar link (Scaffold-ETH 2 style): bg-secondary highlight on
  # active/hover, optional leading icon, no button/border/rounding.
  def nav_link(label, path, icon: nil)
    active = current_page?(path)
    classes = [
      "flex items-center gap-2 h-full px-4 text-sm hover:bg-secondary focus:bg-secondary transition",
      ("bg-secondary" if active)
    ].compact.join(" ")
    link_to path, class: classes do
      safe_join([ icon, tag.span(label) ].compact)
    end
  end

  # Heroicons bug-ant (outline), used for the Debug Contracts menu item like SE-2.
  def bug_ant_icon
    tag.svg(xmlns: "http://www.w3.org/2000/svg", class: "h-4 w-4", fill: "none",
            viewBox: "0 0 24 24", stroke: "currentColor", "stroke-width": "1.5") do
      tag.path("stroke-linecap": "round", "stroke-linejoin": "round",
        d: "M12 12.75c1.148 0 2.278.08 3.383.237 1.037.146 1.866.966 1.866 2.013 0 3.728-2.35 6.75-5.25 6.75S6.75 18.728 6.75 15c0-1.046.83-1.867 1.866-2.013A24.2 24.2 0 0 1 12 12.75Zm0 0c2.883 0 5.647.508 8.207 1.44a23.9 23.9 0 0 1-1.152 6.06M12 12.75c-2.883 0-5.647.508-8.208 1.44.125 2.104.52 4.136 1.153 6.06M12 12.75a2.25 2.25 0 0 0 2.248-2.354M12 12.75a2.25 2.25 0 0 1-2.248-2.354M12 8.25c.995 0 1.971-.08 2.922-.236.403-.066.74-.358.795-.762a3.78 3.78 0 0 0-.399-2.25M12 8.25c-.995 0-1.97-.08-2.922-.236-.402-.066-.74-.358-.795-.762a3.73 3.73 0 0 1 .4-2.253M12 8.25a2.25 2.25 0 0 0-2.248 2.146M12 8.25a2.25 2.25 0 0 1 2.248 2.146M8.683 5a6.03 6.03 0 0 1-1.155-1.002c.07-.63.27-1.222.574-1.747m.581 2.749A3.75 3.75 0 0 1 15.318 5m0 0c.427-.283.815-.62 1.155-.999a4.47 4.47 0 0 0-.575-1.752M4.921 6a24 24 0 0 0-.392 3.314c1.668.546 3.416.914 5.223 1.082M19.08 6c.205 1.08.337 2.187.392 3.314a23.9 23.9 0 0 1-5.223 1.082")
    end
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
