require 'cinch'

module Sponsored
  class Advertiser
    def initialize(message, input_phrase, debug: false)
      @message = message
      @input_phrase = sanitize(input_phrase)
      @debug = debug
    end

    def advertise!
      catch :halt do
        rate_limit do |channel|
          check_ignore_list
          reset_query_rate_limiter
          log_babelfy_tokens

          if any_interesting_words?
            log_search_phrase

            if results?
              log_search_engine
              channel.reset!
              reply_with_result
            else
              log_no_results
            end
          end
        end
      end
    end

    private

    def ad_rate_limiter
      @@ad_rate_limiter ||= AdRateLimiter.new
    end

    def any_interesting_words?
      babelfy_client.most_interesting_words.any?
    end

    def babelfy_client
      @babelfy_client ||= BabelfyClient.new(@input_phrase)
    end

    def check_ignore_list
      if ignore?
        debug "Ignoring message from #{@message.user.nick}"
        throw :halt
      end
    end

    def debug(debug_message = nil)
      if @debug
        debug_message ||= yield
        @message.reply debug_message
      end
    end

    def ignore?
      ignore_list.ignore? @message
    end

    def ignore_list
      @ignore_list ||= IgnoreList.new
    end

    def log_babelfy_tokens
      debug do
        tokens = babelfy_client.tokens_sorted_by_interest.map do |token|
          "#{token.word.inspect}:#{token.score}:#{token.stopword?.inspect}"
        end

        "Tokens: #{tokens.join(', ')}"
      end
    end

    def log_no_results
      debug "No results for #{search.search_phrase.inspect}"
    end

    def log_search_engine
      debug "Search engine: #{search.first_search_with_results.class.name}"
    end

    def log_search_phrase
      debug "Search phrase: #{search.search_phrase.inspect}"
    end

    def query_rate_limiter
      @@query_rate_limiter ||= QueryRateLimiter.new
    end

    def rate_limit(&rate_limited_block)
      if @debug
        rate_limited_block.call DebugChannel.new
      else
        query_rate_limiter.rate_limit do
          ad_rate_limiter.rate_limit @message, &rate_limited_block
        end
      end
    end

    def reply_with_result
      @message.reply result.to_irc
    end

    def reset_query_rate_limiter
      query_rate_limiter.reset!
    end

    def result
      @result ||= search.random_result
    end

    def results?
      search.any?
    end

    def sanitize(text)
      Cinch::Formatting.unformat text
    end

    def search
      @search ||= ExhaustiveSearch.new(search_phrase)
    end

    def search_phrase
      babelfy_client.most_interesting_words.join ' '
    end

    class DebugChannel
      def reset!
        # no-op
      end
    end
  end
end
