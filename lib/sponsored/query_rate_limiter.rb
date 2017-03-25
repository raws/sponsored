require 'thread'
require 'time'

module Sponsored
  class QueryRateLimiter
    DEFAULT_TTL_SECONDS = 5

    def initialize
      @ttl_seconds = ENV.fetch('SPONSORED_QUERY_TTL_SECONDS', DEFAULT_TTL_SECONDS).to_i
      @mutex = Mutex.new
      @last_query_at = nil
    end

    def rate_limit(&rate_limited_block)
      @mutex.synchronize do
        if queryable?
          rate_limited_block.call
        end
      end
    end

    def reset!
      @last_query_at = Time.now
    end

    private

    def never_queried?
      @last_query_at.nil?
    end

    def queryable?
      never_queried? || ttl_expired?
    end

    def seconds_since_last_query
      Time.now - @last_query_at
    end

    def ttl_expired?
      seconds_since_last_query >= @ttl_seconds
    end
  end
end
