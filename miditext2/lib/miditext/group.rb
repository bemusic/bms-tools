
module Miditext
class Group 

  attr_reader :notes
  attr_accessor :target, :output_time, :object_id

  def initialize(notes)
    @notes = notes.sort_by(&:channel)
    @min_time = notes.map(&:start_time).min
    @max_time = notes.map(&:end_time).max
  end

  def to_s
    "Group: #{@notes}"
  end

  def id(options = {})
    notes.map { |note| [ note.id(options), note.start_time - @min_time ] }.sort
  end

  def length
    @max_time - @min_time
  end

  def export(track, start)
    @notes.each do |note|
      note.export(track.events, start + note.time - @min_time)
    end
  end
  
  def gap=(gap)
    @max_time = notes.map { |note| note.end_time + gap.get_gap(note) }.max
  end

  def time
    @min_time
  end

end
end
