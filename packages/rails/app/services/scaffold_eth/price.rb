# frozen_string_literal: true

require "net/http"

module ScaffoldEth
  # Fetches the native-currency USD price (CoinGecko), cached briefly. Powers the
  # footer price pill and the Balance ETH/USD toggle. The Ruby analogue of SE-2's
  # useFetchNativeCurrencyPrice. Returns nil on failure so callers can hide the UI.
  module Price
    CACHE_TTL = 60.seconds
    API = "https://api.coingecko.com/api/v3/simple/price"

    # Map native-currency symbols to CoinGecko ids. Testnet ETH tracks mainnet ETH.
    COINGECKO_IDS = {
      "ETH" => "ethereum",
      "POL" => "matic-network",
      "MATIC" => "matic-network"
    }.freeze

    class << self
      # USD price (Float) for the active chain's native currency, or nil.
      def native_currency(chain = ScaffoldEth::Config.active_chain)
        symbol = chain.symbol.to_s.upcase
        id = COINGECKO_IDS[symbol]
        return nil unless id

        Rails.cache.fetch("scaffold_eth:price:#{id}", expires_in: CACHE_TTL) { fetch(id) }
      end

      private

      def fetch(id)
        uri = URI(API)
        uri.query = URI.encode_www_form(ids: id, vs_currencies: "usd")
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 4) do |http|
          http.get(uri.request_uri)
        end
        return nil unless res.is_a?(Net::HTTPSuccess)

        JSON.parse(res.body).dig(id, "usd")&.to_f
      rescue StandardError => e
        Rails.logger.debug("[ScaffoldEth::Price] #{e.message}")
        nil
      end
    end
  end
end
