

class Slice
  attr_accessor :start_time, :end_time, :beat
  def initialize(start_time, beat)
    @start_time = start_time
    @beat = beat
  end
end

$start = 1

def get_slices(data)
  bpm = 60.0
  grid = 4
  current_beat = 0
  current_time = 0
  slices = []
  last_slice = nil
  data.scan(/([\d\.]+)bpm|(\d+)(?:st|nd|rd|th)|([,;])|(\.)|start=(..)/) do |m_bpm, m_grid, m_slice, m_step, m_start|
    if m_bpm
      bpm = m_bpm.to_f
    end
    if m_grid
      grid = m_grid.to_f
    end
    if m_slice
      last_slice = Slice.new(current_time, current_beat)
      slices << last_slice if m_slice != ';'
      current_time += (4.0 / grid) * 60.0 / bpm
      current_beat += 4.0 / grid
      last_slice.end_time = current_time
    end
    if m_step
      current_time += (4.0 / grid) * 60.0 / bpm
      current_beat += 4.0 / grid
      last_slice.end_time = current_time
    end
    if m_start
      $start = m_start.to_i(36)
    end
  end
  slices
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
  slices = get_slices(File.read(filename))
  dirname, basename = File.split(filename)
  basename = File.basename(basename, '.txt')
  wav_file = File.realpath(File.join(dirname, basename + '.wav'))
  out_dirname = File.join(dirname, 'wav')
  FileUtils::mkdir_p(out_dirname)

  if File.exist?(wav_file)
    IO.popen("actualslicer2/actualslicer2.exe", 'w',
             :out => :out, :err => :err) do |io| #$stdout.tap do |io|
      io << "#{wav_file}\n"
      io << "#{slices.length}\n"
      slices.each_with_index do |slice, index|
        io << "#{File.join(out_dirname, '%s-%03d.wav' % [basename, index + 1])}\n"
        io << "#{slice.start_time} #{slice.end_time}\n"
      end
    end
    puts $?
  end

  builder = IBMSCClipboardDataBuilder.new
  object_id = $start
  slices.each do |slice|
    builder.add(:object_id => object_id, :time => slice.beat)
    object_id += 1
  end
  File.open(File.join(dirname, basename + '.ibmsc-clipboard.txt'), 'wb') do |file|
    file << builder.build
  end
end

