require "faraday"
require "time"
require "bigdecimal"
require "active_support/all"

module Solar
  module Provider
    class Octopus
      def initialize(api_key:)
        @api_key = api_key
        @client = Faraday.new(url: "https://api.octopus.energy") do |f|
          f.request :json
          f.request :authorization, :basic, api_key, ''
          f.response :json
        end
      end

      #: () -> Consumption[]
      def consumption(mpan:, serial:, from:, to: nil)
        response = @client.get("/v1/electricity-meter-points/#{mpan}/meters/#{serial}/consumption/", { 
          period_from: from,
          period_to: to,
          page_size: 25_000
        }.compact)
        
        response.body.dig("results").map do |result|
          Consumption.new(
            provider: "octopus",
            watt_hours: (result.dig("consumption") * 1000).round,
            from: Time.iso8601(result.dig("interval_start")),
            to: Time.iso8601(result.dig("interval_end"))
          )
        end
      end

      def rates(product:, tariff:, direction:)
        from = (Time.now - 3.days).beginning_of_day
        to = (Time.now + 7.days).beginning_of_day
        
        response = @client.get("/v1/products/#{product}/electricity-tariffs/#{tariff}/standard-unit-rates/", {
          period_from: from.iso8601,
          period_to: to.iso8601
        }.compact)

        response.body.dig("results").map do |result|
          Rate.new(
            provider: "octopus",
            direction:,
            tariff:,
            rate: BigDecimal(result.dig("value_inc_vat"), 16) / 100.0,
            from: Time.iso8601(result.dig("valid_from")),
            to: Time.iso8601(result.dig("valid_to"))
          )
        end
      end

      def products
        @client.get("/v1/products/")
      end

      def product(code:)
        @client.get("/v1/products/#{code}/")
      end
    end
  end
end