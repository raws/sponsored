require 'cinch'

module Sponsored
  class Plugin
    include Cinch::Plugin

    listen_to :message, method: :on_message
    match /sponsored/, method: :on_sponsored

    private

    def advertise(message, input_phrase, debug: false)
      Advertiser.new(message, input_phrase, debug: debug).advertise!
    end

    def on_message(message)
      # TODO
    end

    def on_sponsored(message)
      search_phrase = message.message.slice(/\A!sponsored\s+(.*?)\s*\z/, 1)

      if search_phrase
        advertise message, search_phrase, debug: true
      end
    end
  end
end
