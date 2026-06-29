# frozen_string_literal: true

module ScaffoldEth
  # ENS (EIP-137) forward/reverse resolution via eth.rb, used by the Address
  # component and AddressInput. ENS lives on mainnet, so resolution always uses a
  # mainnet client regardless of the app's target network (matching SE-2).
  # Results are cached to avoid hammering the RPC.
  module Ens
    CACHE_TTL = 10.minutes

    class << self
      # ENS name -> checksummed address (or nil).
      def resolve(name)
        return nil if name.blank? || !name.to_s.include?(".")

        cached("ens:fwd:#{name.downcase}") do
          addr = resolver.resolve(name.to_s)
          normalize_address(addr)
        end
      end

      # address -> primary ENS name (or nil).
      def reverse(address)
        return nil if address.blank?

        cached("ens:rev:#{address.downcase}") do
          node_name = "#{address.to_s.sub(/\A0x/, '').downcase}.addr.reverse"
          contract = resolver.resolver(node_name)
          name = client.call(contract, "name", resolver.namehash(node_name))
          name.presence
        end
      end

      # ENS avatar text record for a name (or nil).
      def avatar(name)
        return nil if name.blank?

        cached("ens:avatar:#{name.downcase}") do
          resolver.text(name.to_s, "avatar").presence
        end
      end

      private

      def client
        @client ||= ScaffoldEth::Client.for("mainnet").eth
      end

      def resolver
        @resolver ||= ::Eth::Ens::Resolver.new(client)
      end

      def normalize_address(addr)
        return nil if addr.blank?

        a = addr.is_a?(::Eth::Address) ? addr.to_s : addr.to_s
        return nil if a == ::Eth::Ens::DEFAULT_ADDRESS || a =~ /\A0x0+\z/

        ::Eth::Address.new(a).checksummed
      rescue StandardError
        nil
      end

      # Cache wrapper that swallows RPC errors (e.g. offline local dev) -> nil.
      def cached(key)
        Rails.cache.fetch(key, expires_in: CACHE_TTL) do
          begin
            yield
          rescue StandardError => e
            Rails.logger.debug("[ScaffoldEth::Ens] #{key} failed: #{e.message}")
            nil
          end
        end
      end
    end
  end
end
