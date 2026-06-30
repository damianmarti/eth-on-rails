Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions.
  get "up" => "rails/health#show", as: :rails_health_check

  # --- ETH-on-Rails pages (Scaffold-ETH 2 parity) ---
  root "home#index"

  # Debug Contracts — auto-generated UI from each contract's ABI
  get "debug", to: "debug#index", as: :debug
  get "debug/:contract", to: "debug#show", as: :debug_contract

  # Block Explorer (local-chain explorer powered by eth.rb)
  get "blockexplorer", to: "block_explorer#index", as: :block_explorer
  get "blockexplorer/search", to: "block_explorer#search", as: :block_explorer_search
  get "blockexplorer/block/:id", to: "block_explorer#block", as: :block_explorer_block
  get "blockexplorer/tx/:hash", to: "block_explorer#transaction", as: :block_explorer_tx
  get "blockexplorer/address/:address", to: "block_explorer#address", as: :block_explorer_address

  # Faucet
  get "faucet", to: "faucet#index", as: :faucet

  # --- JSON API consumed by the Stimulus/JS layer (eth.rb-backed) ---
  namespace :api do
    get "config", to: "config#show"
    get "price", to: "price#show"
    get "contracts", to: "contracts#index"
    get "contracts/:name", to: "contracts#show", as: :contract
    get "read", to: "reads#show"
    get "events", to: "events#index"
    get "ens", to: "ens#show"
    resource :faucet, only: %i[create show], controller: "faucet"
    # Block explorer JSON (used for live indexer updates)
    get "blocks", to: "blocks#index"
  end
end
