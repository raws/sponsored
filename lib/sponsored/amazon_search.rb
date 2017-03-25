require 'base64'
require 'nokogiri'
require 'openssl'
require 'sponsored/search'
require 'time'
require 'uri'

module Sponsored
  class AmazonSearch < Search
    REQUEST_HOST = 'webservices.amazon.com'
    REQUEST_PATH = '/onca/xml'
    URI_ESCAPE_PATTERN = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")

    def results
      @results ||= parsed_response.css('Item').map { |element| Result.new(element) }
    end

    private

    def canonical_query_string
      @canonical_query_string ||= params.sort.map do |key, value|
        escaped_key = uri_escape(key)
        escaped_value = uri_escape(value.to_s)
        [escaped_key, escaped_value].join '='
      end.join('&')
    end

    def params
      @params ||= {
        'AssociateTag' => ENV['AMAZON_ASSOCIATE_ID'],
        'AWSAccessKeyId' => ENV['AWS_ACCESS_KEY_ID'],
        'Keywords' => @search_phrase,
        'Operation' => 'ItemSearch',
        'ResponseGroup' => 'Images,ItemAttributes,Offers',
        'SearchIndex' => 'All',
        'Service' => 'AWSECommerceService',
        'Timestamp' => Time.now.gmtime.iso8601
      }
    end

    def parsed_response
      @parsed_response ||= Nokogiri::XML(response.body.to_s)
    end

    def response
      @response ||= HTTP.get(signed_url).tap do |response|
        unless response.code == 200
          raise AmazonSearchError
        end
      end
    end

    def signature
      hmac_digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'),
        ENV['AWS_SECRET_ACCESS_KEY'], string_to_sign)
      Base64.encode64(hmac_digest).strip
    end

    def signed_url
      escaped_signature = uri_escape(signature)
      "https://#{REQUEST_HOST}#{REQUEST_PATH}?#{canonical_query_string}" \
        "&Signature=#{escaped_signature}"
    end

    def string_to_sign
      "GET\n#{REQUEST_HOST}\n#{REQUEST_PATH}\n#{canonical_query_string}"
    end

    def uri_escape(string)
      URI.escape string, URI_ESCAPE_PATTERN
    end

    class AmazonSearchError < StandardError; end

    class Result
      attr_reader :image_url, :price, :title, :url

      def initialize(element)
        @element = element
        @image_url = @element.at_css('LargeImage > URL')&.text
        @title = @element.at_css('ItemAttributes > Title')&.text
        @price = Price.new(lowest_new_price || lowest_used_price || list_price)
        @url = @element.at_css('DetailPageURL')&.text
      end

      def inspect
        "#<#{self.class.name} title=#{title[0..30].strip.inspect} price=#{price.inspect}>"
      end

      def short_url
        @short_url ||= BitlyClient.new(url).short_url
      end

      def to_irc
        Cinch::Formatting.format(:green, :bold, title) + " #{price.formatted} #{short_url}"
      end

      private

      def list_price
        @element.at_css('ItemAttributes > ListPrice')
      end

      def lowest_new_price
        @element.at_css('OfferSummary > LowestNewPrice')
      end

      def lowest_used_price
        @element.at_css('OfferSummary > LowestUsedPrice')
      end
    end

    class Price
      include Comparable

      attr_reader :amount, :formatted

      def initialize(element)
        @element = element
        @amount = @element&.at_css('Amount')&.text.to_i || 0
        @formatted = @element&.at_css('FormattedPrice')&.text || '$0'
      end

      def inspect
        formatted
      end

      def <=>(other)
        amount <=> other.amount
      end
    end
  end
end
