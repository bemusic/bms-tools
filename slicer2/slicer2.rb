#!/usr/bin/env ruby

class Slice
  attr_accessor :start_time, :end_time, :beat, :group
  attr_reader :id
  def initialize(start_time, beat, id)
    @start_time = start_time
    @beat = beat
    @id = id
  end
end

class Group
  attr_accessor :samples, :filename
  attr_reader :id
  def initialize(id)
    @samples = []
    @id = id
  end
  def sample
    @samples[0]
  end
end

$start = 1

def get_slices(data)
  bpm = 60.0
  grid = 4
  current_beat = 0
  current_time = 0
  slices = []
  groups = []
  defs = { }
  ref = nil
  last_slice = nil
  id = 0
  data.scan(/([\d\.]+)bpm|(\d+)(?:st|nd|rd|th)|([,;])|(\.)|start=(..)|#(\S)|\^(\S)|(\$)/) do |
      m_bpm, m_grid, m_slice, m_step, m_start, m_def, m_ref, m_reset|
    case
    when m_bpm
      bpm = m_bpm.to_f
    when m_grid
      grid = m_grid.to_f
    when m_slice
      id += 1
      last_slice = Slice.new(current_time, current_beat, id)
      slices << last_slice
      use_sample = m_slice != ';'
      current_time += (4.0 / grid) * 60.0 / bpm
      current_beat += 4.0 / grid
      last_slice.end_time = current_time
      last_slice.group = begin
        if ref
          slices[ref].tap { ref += 1 }.group
        else
          Group.new(groups.length).tap { |g| groups << g }
        end
      end
      last_slice.group.samples << last_slice if use_sample
    when m_step
      current_time += (4.0 / grid) * 60.0 / bpm
      current_beat += 4.0 / grid
      last_slice.end_time = current_time if last_slice
    when m_start
      $start = m_start.to_i(36)
    when m_def
      defs[m_def] = slices.length
    when m_ref
      ref = defs[m_ref] or raise "Unknown ref #{m_ref}"
    when m_reset
      ref = nil
    end
  end
  return [slices, groups]
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


require 'fileutils'

ARGV.each do |filename|
  slices, groups = get_slices(File.read(filename))
  dirname, basename = File.split(filename)
  basename = File.basename(basename, '.txt')
  wav_file = File.realpath(File.join(dirname, basename + '.wav'))
  out_dirname = File.join(dirname, 'wav')
  FileUtils::mkdir_p(out_dirname)

  files = []

  if File.exist?(wav_file)
    exe = File.join(File.dirname(__FILE__), 'actualslicer2', 'actualslicer2')
    IO.popen(exe, 'w',
             :out => :out, :err => :err) do |io| #$stdout.tap do |io|
      io << "#{wav_file}\n"
      groups_with_sample = groups.select(&:sample)
      io << "#{groups_with_sample.length}\n"
      groups_with_sample.each do |group|
        slice = group.sample
        filename = '%s-%03d.wav' % [basename, group.id + 1]
        group.filename = filename
        files << filename
        io << "#{File.join(out_dirname, filename)}\n"
        io << "#{slice.start_time} #{slice.end_time}\n"
      end
    end
    puts $?
  end

  files.sort!

  builder = IBMSCClipboardDataBuilder.new
  slices.each do |slice|
    next unless slice.group.filename
    object_id = $start + files.index(slice.group.filename)
    builder.add(:object_id => object_id, :time => slice.beat)
  end
  File.open(File.join(dirname, basename + '.ibmsc-clipboard.txt'), 'wb') do |file|
    file << builder.build
  end
end

