require 'digest'
require 'time'

module Solar
  module Battery
    class Fox
      class Middleware < Faraday::Middleware
        def initialize(app, api_key:)
          super(app)
          @api_key = api_key
        end

        def call(env)
          add_signing_headers(env)
          @app.call(env)
        end

        private

        def add_signing_headers(env)
          path = env.url.path
          timestamp = (Time.now.to_f * 1000).round
          signature_string = "#{path}\\r\\n#{@api_key}\\r\\n#{timestamp}"
          signature = Digest::MD5.hexdigest(signature_string)

          env.request_headers.merge!(
            'token' => @api_key,
            'lang' => 'en',
            'timestamp' => timestamp.to_s,
            'signature' => signature
          )
        end
      end
    end
  end
end
