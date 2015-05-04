
require_relative '../matchparser'

module Miditext

  class Grouper
  end

  class NoteGrouper < Grouper
    def group(notes)
      notes.map { |note| Group.new([ note ]) }
    end
  end

  class TimeGrouper < Grouper
    def group(notes)
      notes.group_by(&:time)
           .map { |key, list| Group.new(list) }
           .sort_by(&:time)
    end
  end

  class PatternGrouper < Grouper
    def initialize(filename, ppqn)
      bpm = 60.0
      grid = 4
      current = 0
      positions = []
      MatchParser::parse File.read(filename) do |pattern|
        pattern.match /([\d\.]+)bpm/ do |match|
          bpm = match[1].to_f
        end
        pattern.match /(\d+)(?:st|nd|rd|th)/ do |match|
          grid = match[1].to_f
        end
        pattern.match /,/ do |match|
          positions << current * ppqn
          current += 4.0 / grid
        end
        pattern.match /\./ do |match|
          current += 4.0 / grid
        end
      end
      @positions = positions
    end
    def get_index(time)
      index = 0
      @positions.each_with_index do |position, i|
        if time >= position
          index = i
        else
          break
        end
      end
      index
    end
    def group(notes)
      notes.group_by { |note| get_index(note.time) }
           .map { |index, list| Group.new(list) }
    end
  end

end
