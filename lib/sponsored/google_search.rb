require 'http'
require 'sponsored/search'

module Sponsored
  class GoogleSearch < Search
    GOOGLE_SEARCH_URL = 'https://www.googleapis.com/customsearch/v1'
    SEARCH_RESULT_LIMIT = 3

    def results
      @results ||= response.parse['items'].map { |attributes| Result.new(attributes) }
    end

    private

    def params
      {
        cx: ENV['GOOGLE_CUSTOM_SEARCH_ENGINE_ID'],
        key: ENV['GOOGLE_API_KEY'],
        num: SEARCH_RESULT_LIMIT,
        q: @search_phrase
      }
    end

    def response
      @response ||= HTTP.get(GOOGLE_SEARCH_URL, params: params).tap do |response|
        unless response.code == 200
          raise GoogleSearchError
        end
      end
    end

    class GoogleSearchError < StandardError; end

    class Result
      attr_reader :title, :url

      def initialize(attributes)
        @title = attributes['title']
        @url = attributes['link']
      end

      def inspect
        "#<#{self.class.name} title=#{title[0..30].strip.inspect}>"
      end

      def short_url
        @short_url ||= BitlyClient.new(url).short_url
      end

      def to_irc
        Cinch::Formatting.format(:green, :bold, title) + " #{url_shortened_if_necessary}"
      end

      def url_shortened_if_necessary
        if url.length > 128
          short_url
        else
          url
        end
      end
    end
  end
end
