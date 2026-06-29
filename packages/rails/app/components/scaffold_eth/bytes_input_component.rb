# frozen_string_literal: true

module ScaffoldEth
  # Hex bytes / bytes32 input. The `bytes-input` Stimulus controller validates the
  # 0x-hex (and length for fixed bytesN). Mirrors SE-2's <BytesInput /> / <Bytes32Input />.
  class BytesInputComponent < ViewComponent::Base
    def initialize(name:, sol_type: "bytes", value: nil)
      @name = name
      @sol_type = sol_type
      @value = value
    end

    # Fixed-size byte length, e.g. 32 for bytes32, or nil for dynamic bytes.
    def fixed_length
      m = @sol_type.to_s.match(/\Abytes(\d+)\z/)
      m && m[1].to_i
    end
  end
end
