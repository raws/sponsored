require 'sponsored/amazon_search'
require 'sponsored/google_search'

module Sponsored
  class ExhaustiveSearch
    SEARCH_ENGINES = [AmazonSearch, GoogleSearch]

    attr_reader :search_phrase

    def initialize(search_phrase)
      @search_phrase = search_phrase
    end

    def any?
      results.any?
    end

    def first_search_with_results
      @first_search_with_results ||= searches.find(&:any?)
    end

    def random_result
      results.sample
    end

    def results
      @results ||= first_search_with_results&.results || []
    end

    private

    def searches
      @searches ||= SEARCH_ENGINES.map { |engine| engine.new(search_phrase) }
    end
  end
end
