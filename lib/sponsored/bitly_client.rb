module Sponsored
  class BitlyClient
    SHORTEN_ENDPOINT = 'https://api-ssl.bitly.com/v3/shorten'

    def initialize(long_url)
      @long_url = long_url
    end

    def short_url
      @short_url ||= response.body.to_s.strip
    end

    private

    def params
      {
        'access_token' => ENV['BITLY_OAUTH_TOKEN'],
        'format' => 'txt',
        'longUrl' => @long_url
      }
    end

    def response
      @response ||= HTTP.get(SHORTEN_ENDPOINT, params: params).tap do |response|
        unless response.code == 200
          raise BitlyRequestError
        end
      end
    end

    class BitlyRequestError < StandardError; end
  end
end
