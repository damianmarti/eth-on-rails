# frozen_string_literal: true

module ScaffoldEth
  # Dispatches an ABI function input to the right specialized input component
  # based on its Solidity type. Used by the Debug page write/read forms.
  class ContractInputComponent < ViewComponent::Base
    def initialize(abi_input:, index:, function_name:)
      @abi_input = abi_input
      @index = index
      @function_name = function_name
    end

    def sol_type = @abi_input["type"]

    # Form field name; the write serializer reads data-scaffold-arg-* attributes.
    def field_name
      "#{@function_name}__arg#{@index}"
    end

    def label
      name = @abi_input["name"].presence || "arg#{@index}"
      "#{name} (#{sol_type})"
    end

    def input_component
      case sol_type
      when "address"
        ScaffoldEth::AddressInputComponent.new(name: field_name)
      when /\A(u?int)\d*\z/
        ScaffoldEth::IntegerInputComponent.new(name: field_name, sol_type: sol_type)
      when /\Abytes/
        ScaffoldEth::BytesInputComponent.new(name: field_name, sol_type: sol_type)
      when "bool"
        nil # rendered inline as a select in the template
      else
        # string, tuples, arrays -> plain text (JSON for complex types)
        ScaffoldEth::BaseInputComponent.new(
          name: field_name, placeholder: sol_type, sol_type: sol_type
        )
      end
    end
  end
end
