module Solar
  module Notify
    class Telegram
      def initialize(token:, chat_id:)
        @token = token
        @chat_id = chat_id
        @client = Faraday.new(url: "https://api.telegram.org") do |f|
          f.request :json
          f.response :json
        end
      end

      def send_message(message)
        response = @client.post("/bot#{@token}/sendMessage", {
          chat_id: @chat_id,
          text: message
        }.to_json)

        response.body
      end
    end
  end
end