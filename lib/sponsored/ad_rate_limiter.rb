require 'thread'
require 'time'

module Sponsored
  class AdRateLimiter
    def initialize
      @channels = Hash.new { |channels, channel| channels[channel] = Channel.new(channel) }
      @ignore_list = IgnoreList.new
      @mutex = Mutex.new
    end

    def rate_limit(message, &rate_limited_block)
      return if ignore?(message)

      @mutex.synchronize do
        if rate_limited?(message)
          channel(message).message!
        else
          rate_limited_block.call channel(message)
        end
      end
    end

    private

    def channel(message)
      @channels[message.channel.name]
    end

    def ignore?(message)
      @ignore_list.ignore? message
    end

    def rate_limited?(message)
      channel(message).rate_limited?
    end

    class Channel
      DEFAULT_TTL_MESSAGES = 15
      DEFAULT_TTL_SECONDS = 3600

      def initialize(channel)
        @channel = channel
        @ttl_messages = ENV.fetch('SPONSORED_CHANNEL_AD_TTL_MESSAGES', DEFAULT_TTL_MESSAGES).to_i
        @ttl_seconds = ENV.fetch('SPONSORED_CHANNEL_AD_TTL_SECONDS', DEFAULT_TTL_SECONDS).to_i

        @last_advertised_at = nil
        @messages_since_last_ad = 0
      end

      def inspect
        "#<#{self.class.name} channel=#{@channel.inspect} " \
          "last_advertised_at=#{@last_advertised_at&.iso8601.inspect} " \
          "messages_since_last_ad=#{@messages_since_last_ad}>"
      end

      def message!
        @messages_since_last_ad += 1
      end

      def rate_limited?
        !advertisable?
      end

      def reset!
        @last_advertised_at = Time.now
        @messages_since_last_ad = 0
      end

      private

      def advertisable?
        eligible_for_first_ad? || ttl_expired?
      end

      def eligible_for_first_ad?
        @last_advertised_at.nil? && enough_messages_since_last_ad?
      end

      def enough_messages_since_last_ad?
        @messages_since_last_ad >= @ttl_messages
      end

      def seconds_since_last_ad
        if @last_advertised_at
          Time.now - @last_advertised_at
        else
          0
        end
      end

      def ttl_expired?
        seconds_since_last_ad >= @ttl_seconds && enough_messages_since_last_ad?
      end
    end
  end
end
