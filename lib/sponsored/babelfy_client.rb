require 'http'

module Sponsored
  class BabelfyClient
    BABELFY_URL = 'https://babelfy.io/v1/disambiguate'
    MINIMUM_INTERESTING_SCORE = 0.1

    def initialize(text)
      @text = scrub_uris(text)
    end

    def interesting_tokens
      @interesting_tokens ||= tokens_sorted_by_interest.select do |token|
        !token.stopword? && token.score >= MINIMUM_INTERESTING_SCORE
      end
    end

    def most_interesting_words
      @most_interesting_words ||= interesting_tokens.first(2).map(&:word)
    end

    def tokens
      @tokens ||= response.parse.map do |token_attributes|
        BabelfyToken.new @text, token_attributes
      end
    end

    def tokens_sorted_by_interest
      tokens.sort_by { |token| [token.score, token.word.length, token.word] }.reverse
    end

    private

    def params
      {
        key: ENV['BABELNET_API_KEY'],
        lang: 'AGNOSTIC',
        text: @text
      }
    end

    def response
      @response ||= HTTP.get(BABELFY_URL, params: params).tap do |response|
        unless response.code == 200
          raise BabelfyRequestError
        end
      end
    end

    def scrub_uris(text)
      text.gsub(/\w+:\/\/\S+/, '').squeeze(' ').strip
    end

    class BabelfyRequestError < StandardError; end

    class BabelfyToken
      attr_reader :score, :word

      def initialize(input_text, token_attributes)
        @word = word_from_input_and_token_attributes(input_text, token_attributes)
        @score = token_attributes['globalScore']
      end

      def inspect
        "#<#{self.class.name} word=#{word.inspect} score=#{score.inspect} " \
          "stopword=#{stopword?.inspect}>"
      end

      def stopword?
        stopwords.include? word.gsub(/[^\w]/, '').downcase
      end

      private

      def stopwords
        @@stopwords ||= File.read(File.join(File.dirname(__FILE__),
          '../../share/stopwords.txt')).split("\n")
      end

      def word_from_input_and_token_attributes(input_text, token_attributes)
        range = token_attributes['charFragment']['start']..token_attributes['charFragment']['end']
        input_text[range]
      end
    end
  end
end
