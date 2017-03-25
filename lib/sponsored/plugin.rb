require 'cinch'

module Sponsored
  class Plugin
    include Cinch::Plugin

    listen_to :channel, method: :on_message
    match /sponsored/, method: :on_sponsored

    private

    def advertise(message, input_phrase, debug: false)
      Advertiser.new(message, input_phrase, debug: debug).advertise!
    end

    def on_message(message)
      input_phrase = message.message
      advertise message, input_phrase
    end

    def on_sponsored(message)
      input_phrase = message.message.slice(/\A!sponsored\s+(.*?)\s*\z/, 1)

      if input_phrase
        advertise message, input_phrase, debug: true
      end
    end
  end
end
