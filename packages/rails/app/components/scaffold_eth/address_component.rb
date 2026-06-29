# frozen_string_literal: true

module ScaffoldEth
  # Displays an Ethereum address: blockie avatar + (ENS name or shortened
  # address) + copy button + block-explorer link. ENS is resolved server-side
  # via eth.rb (mainnet). Mirrors SE-2's <Address /> component.
  class AddressComponent < ViewComponent::Base
    def initialize(address:, size: "base", format: "short", placeholder: nil, link: true, resolve_ens: true)
      @address = address.presence
      @size = size
      @format = format
      @placeholder = placeholder
      @link = link
      @resolve_ens = resolve_ens
    end

    def address? = @address.present?

    def checksummed
      ::Eth::Address.new(@address).checksummed
    rescue StandardError
      @address
    end

    def ens_name
      return nil unless @resolve_ens && address?

      @ens_name ||= ScaffoldEth::Ens.reverse(@address)
    rescue StandardError
      nil
    end

    def display_label
      return ens_name if ens_name.present?
      return checksummed if @format == "long"

      helpers.short_address(checksummed)
    end

    def explorer_url
      return nil unless @link && address?

      helpers.explorer_address_url(checksummed)
    end

    def text_size_class
      { "xs" => "text-xs", "sm" => "text-sm", "base" => "text-base",
        "lg" => "text-lg", "xl" => "text-xl" }.fetch(@size, "text-base")
    end

    def blockie_size
      { "xs" => 16, "sm" => 20, "base" => 24, "lg" => 32, "xl" => 40 }.fetch(@size, 24)
    end
  end
end
