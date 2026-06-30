class ExampleController < ApplicationController
  # A worked example showing how to read a value from a contract, send a write
  # transaction, and display an event change-log using the scaffold helpers.
  def index
    @contract = ScaffoldEth::ContractRegistry.contract("YourContract")
  end
end
