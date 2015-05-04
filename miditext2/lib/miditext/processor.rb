
require_relative './gap'

module Miditext

class Processor

  def self.read_midi_sequence(filename)
    MIDI::Sequence.new.tap do |sequence|
      File.open(filename, 'rb') do |file|
        sequence.read(file)
      end
    end
  end

  def self.buffer_id(midi_event)
    [ midi_event.channel, midi_event.note ]
  end

  def self.extract_notes(sequence)
    buffer = {}
    sequence.each_with_object([]) do |track, list|
      track.each do |event|
        if MIDI::NoteOff === event || (MIDI::NoteOn === event && event.velocity == 0)
          buffer_id = self.buffer_id(event)
          note = buffer.delete(buffer_id)
          if note
            note.end = event.time_from_start
            list << note
          else
            puts "Error: note off before note on: #{event}"
          end
        elsif MIDI::NoteOn === event
          buffer_id = self.buffer_id(event)
          note = Note.new(event.channel, event.note, event.velocity, event.time_from_start)
          buffer[buffer_id] = note
        end
      end
    end
  end

  def self.merge_groups(groups, classifier)
    puts " - groups:"
    groups.each_with_index
          .group_by { |group, index| classifier.classify(group) }
          .map { |id, similar_groups|
            representative, r_index = similar_groups.first
            similar_groups.each do |group, index|
              group.target = representative
            end
            puts "    + #{representative}"
            [representative, r_index]
          }
          .sort_by(&:last)
          .map(&:first)
  end

  def self.extract_option(basename, pattern, &block)
    basename.gsub!(pattern) { |match| block.call($1); "" }
  end

  def self.get_options(filename)

    dirname, basename = File.split(filename)
    basename[/\.mid$/i] = ''

    options = {}
    
    extract_option(basename, /,bpm=([0-9\.]+)/) { |data| options[:bpm] = data.to_f }
    extract_option(basename, /,gap=([0-9\.]+)/) { |data| options[:gap] = data.to_f }
    extract_option(basename, /,nolength/) { |data| options[:no_length] = true }
    extract_option(basename, /,pattern/) { |data| options[:grouper] = :pattern }
    extract_option(basename, /,time/) { |data| options[:grouper] = :time }
    extract_option(basename, /,start=([0-9a-zA-Z]+)/) { |data| options[:start] = data.to_i(36) }

    options[:output] = File.join(dirname, basename)
    options

  end

  def self.process!(filename)

    puts "Processing #{filename}"

    # read sequence
    sequence = Processor.read_midi_sequence(filename)
    
    # parse options
    options = Processor.get_options(filename)

    # processor!!
    processor = Processor.new(sequence, options)
    processor.process!

  end

  attr_accessor :sequence

  def initialize(sequence, options)

    @sequence = sequence
    @ppqn = sequence.ppqn

    @output = options[:output]
    @bpm = options[:bpm] || sequence.beats_per_minute
    @gap = Gap.new(@ppqn * (options[:gap] || 1))

    @start_object_id = options[:start] || 1

    @grouper = case options[:grouper]
               when :time; TimeGrouper.new
               when :pattern; PatternGrouper.new("#{@output}.txt", @ppqn)
               else; NoteGrouper.new
               end

    @classifier = if options[:no_length]
                    NoLengthClassifier.new
                  else
                    Classifier.new
                  end

  end

  def process!

    # extract notes
    notes = Processor.extract_notes(@sequence)
    puts " - #{notes.length} notes"

    # turn note into groups
    @raw_groups = @grouper.group(notes)
    puts " - #{@raw_groups.length} groups"

    # remove duplicated groups
    @groups = Processor.merge_groups(@raw_groups, @classifier)
    puts " - #{@groups.length} unique groups"

    # write groups into new sequence
    @result = create_output_sequence

    write_midi!
    write_sound_slicer_file!
    write_ibmsc_file!

  end

  private
  def write_midi!
    filename = "#{@output}-notes.mid"
    puts " - writing #{filename}"
    File.open(filename, 'wb') do |file|
      @result.write(file)
    end
  end

  def write_sound_slicer_file!
    time = 0
    filename = "#{@output}-notes.txt"
    puts " - writing #{filename}"
    File.open(filename, 'w') do |file|
      writer = SoundSlicerWriter.new(file,
                                     :bpm => @bpm,
                                     :grid => @sequence.ppqn * 4)
      @groups.each do |group|
        writer.hold_until group.output_time
        writer.write_note
        writer.hold_until group.output_time + group.length
      end
    end
  end

  def write_ibmsc_file!
    filename = "#{@output}.ibmsc-clipboard.txt"
    puts " - writing #{filename}"
    File.open(filename, 'wb') do |file|
      builder = IBMSCClipboardDataBuilder.new
      @raw_groups.each do |group|
        builder.add(:object_id => group.target.object_id,
                   :time => group.time.to_f / @ppqn)
      end
      file << builder.build
    end
  end

  def create_output_sequence

    source = @sequence
    sequence = MIDI::Sequence.new

    %w{numer denom clocks qnotes ppqn}.each do |prop|
      sequence.send "#{prop}=", source.send(prop)
    end

    meta_track = MIDI::Track.new(sequence)
    meta_track.events = source.tracks[0].events

    track = MIDI::Track.new(sequence)
    start = 0

    next_object_id = @start_object_id

    @groups.each do |group|
      group.gap = @gap
      group.object_id = next_object_id
      next_object_id += 1
      group.output_time = start
      group.export(track, start)
      start += group.length
    end

    track.sort

    sequence.tracks << meta_track
    sequence.tracks << track
    sequence

  end

end

class SoundSlicerWriter
  def initialize(file, options = {})
    @file = file
    @time = 0
    @file << "#{options[:bpm]}bpm\n"
    @file << "#{options[:grid]}th\n"
  end
  def hold_until(time)
    while @time < time
      @file << '.'
      @time += 1
    end
    self
  end
  def write_note
    @file << "\n,"
    @time += 1
    self
  end
end

class IBMSCClipboardDataBuilder
  def initialize(options = {})
    @data = Hash.new { |hash, key| hash[key] = [] }
  end
  def add(attributes = {})
    time = (attributes[:time] * 48).round
    @data[time] << attributes[:object_id]
  end
  def build
    out = "iBMSC Clipboard Data xNT\r\n"
    out << @data.map { |time, ids|
                  channel = 26
                  ids.sort.map { |id| ("%d %d %d %d %d" % [channel, time, id * 10000, 0, 0]).tap { channel += 1 } }
                }
                .flatten
                .join("\r\n")
    out << "\r\n"
  end
end

end
