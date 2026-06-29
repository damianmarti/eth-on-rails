# frozen_string_literal: true

module ScaffoldEth
  # Renders a deterministic blockie avatar for an address. The image is generated
  # client-side from `ethereum-blockies-base64` by the `blockie` Stimulus
  # controller. Mirrors SE-2's <BlockieAvatar />.
  class BlockieAvatarComponent < ViewComponent::Base
    def initialize(address:, size: 24)
      @address = address
      @size = size
    end
  end
end
