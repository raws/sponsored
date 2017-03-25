module Sponsored
  class Search
    attr_reader :search_phrase

    def initialize(search_phrase)
      @search_phrase = search_phrase
    end

    def any?
      results.any?
    end

    def inspect
      "#<#{self.class.name} search=#{search_phrase.inspect}>"
    end

    def random_result
      results.sample
    end

    def results
      []
    end
  end
end
