# frozen_string_literal: true

module ScaffoldEth
  # Address input with live validation + ENS resolution (via /api/ens) and a
  # blockie preview. Mirrors SE-2's <AddressInput />.
  class AddressInputComponent < ViewComponent::Base
    def initialize(name:, value: nil, placeholder: "address or ENS (0x… / name.eth)")
      @name = name
      @value = value
      @placeholder = placeholder
    end
  end
end
