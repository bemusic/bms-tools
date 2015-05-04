
module MatchParser

  class PatternDefinition
    attr_reader :list
    def initialize
      @list = []
    end
    def match(regex, &block)
      @list << [regex, block]
    end
  end

  def self.parse(text)
    definition = PatternDefinition.new
    yield definition
    loop do
      matches = definition.list.map do |regex, block|
        match = regex.match(text)
        match ? [ match.offset(0), regex, match, block ] : nil
      end.reject(&:nil?)
      break if matches.empty?
      matches.min_by(&:first).tap do |offset, regex, match, block|
        text[regex] = ''
        block.call(match)
      end
    end
  end

end
