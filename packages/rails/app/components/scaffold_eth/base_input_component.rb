# frozen_string_literal: true

module ScaffoldEth
  # Foundational text input with Scaffold-ETH styling. Other inputs build on this.
  # `stimulus` adds a data-controller for type-specific behavior (validation/conversion).
  class BaseInputComponent < ViewComponent::Base
    def initialize(name:, value: nil, placeholder: "", stimulus: nil, type: "text",
                   sol_type: nil, disabled: false, arg: true, data: {}, components: nil)
      @name = name
      @value = value
      @placeholder = placeholder
      @stimulus = stimulus
      @type = type
      @sol_type = sol_type
      @disabled = disabled
      @arg = arg
      @data = data
      @components = components
    end

    # Whether this input is collected as an ABI argument by the write serializer.
    def arg? = @arg

    def data_attrs
      attrs = @data.dup
      attrs[:controller] = @stimulus if @stimulus
      # Used by the write-form serializer to know the ABI type per field.
      attrs["scaffold-arg-name"] = @name
      attrs["scaffold-arg-type"] = @sol_type if @sol_type
      # Tuple component metadata so the arg parser can convert tuple integer
      # fields to BigInt (see lib/args.js). Present only for tuple types.
      attrs["scaffold-arg-components"] = @components.to_json if @components.present?
      attrs
    end
  end
end
