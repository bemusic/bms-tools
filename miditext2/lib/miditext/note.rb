
module Miditext
class Note

  attr_reader :channel, :note, :velocity
  attr_writer :end

  def initialize(channel, note, velocity, start)
    @channel = channel
    @note = note
    @velocity = velocity
    @start = start
  end

  def id(options = {})
    [ @channel, @note, @velocity, options[:length] == false ? false : length ]
  end

  def length
    @end - @start
  end

  def length=(length)
    @end = @start + length
  end

  def time
    @start
  end
  
  alias_method :start_time, :time

  def end_time
    @end
  end

  def to_s
    "Note channel=#{@channel} note=#{@note} time=#{time} length=#{length}"
  end

  def export(events, start)
    on = MIDI::NoteOn.new(channel, note, velocity)
    on.time_from_start = start.round
    off = MIDI::NoteOff.new(channel, note, 0)
    off.time_from_start = (start + length).round
    events << on
    events << off
  end

end
end

