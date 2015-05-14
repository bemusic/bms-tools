
module BMSCompiler

  FILENAME_STRATEGIES = [
    -> f { f.sub(/_src(\.\w+)$/, '\1') },
    -> f { f.sub(/(?:\.\w+)?$/, '_key' + File.extname(f)) },
  ]

  class Compiler

    def self.compile(filename)
      Logger.log "Processing: #{filename}"
      text = File.read(filename)
      keysounder = Keysounder.new(text)
      keysounder.process!
      target_filename = get_target_filename(filename)
      if target_filename == filename
        raise "Target filename is same as input filename!"
      end
      Logger.log "Writing to #{target_filename}"
      File.write(target_filename, keysounder.output)
    end

    def self.get_target_filename(filename)
      FILENAME_STRATEGIES.each do |strategy|
        target_filename = strategy.call(filename)
        return target_filename if target_filename != filename
      end
      raise "Unable to derive a file name!"
    end

  end

  class Keysounder
    def initialize(text)
      @text = text
    end
    def process!
      load_bms!
      process_objects!
    end
    def output
      @lines.join
    end
    private
    def load_bms!
      @lines = @text.split(/\r\n|\r|\n/).map { |line| parse_line("#{line}\r\n") }
      @objects = generate_objects!
    end
    def process_objects!
      groups  = @objects.group_by(&:position)
      Logger.log "Found #{@objects.length} note objects on #{groups.length} rows."
      lnhead  = { }
      replaced = 0
      groups.keys.sort.each do |position|
        objects = groups[position]
        notes   = objects.reject(&:bgm?)
        bgm     = { }.tap do |hash|
          objects.select(&:bgm?).each do |object|
            hash[object.channel] = object
          end
        end
        used    = { }
        notes.each do |object|
          if object.ln? && lnhead[object.channel]
            object.value = lnhead.delete(object.channel).value
          else
            if object.value =~ /^Z([1-9A-Y])$/i
              bgm_channel = "b#{$1.to_i(36)}"
              key = bgm[bgm_channel]
              if key
                Logger.warn position, "Reusing #{bgm_channel} (#{used[bgm_channel]})" if used[bgm_channel]
                used[bgm_channel] ||= key.value
                object.value = used[bgm_channel]
                key.value = '00'
                replaced += 1
              else
                Logger.warn position, "Keysound at #{bgm_channel} not found"
                p bgm.values.map(&:channel)
              end
            end
            lnhead[object.channel] = object if object.ln?
          end
        end
      end
      Logger.log "Replaced #{replaced} notes."
    end
    def parse_line(text)
      BMSLine.new(text)
    end
    def generate_objects!
      resolver = BMSChannelResolver.new
      [].tap do |objects|
        @lines.each do |line|
          sentence = BMSChannelSentence.parse(line, resolver)
          next unless sentence
          if sentence.channel =~ /^(?:[123457]\S|b\d+)$/
            objects.push(*sentence.objects)
          end
        end
      end
    end
  end

  class BMSChannelResolver
    def initialize
      @hash = Hash.new(0)
    end
    def resolve(measure, channel)
      if channel == '01'
        @hash[measure] += 1
        "b#{@hash[measure]}"
      else
        channel
      end
    end
  end

  class BMSLine
    attr_reader :text
    def initialize(line)
      @text = line
    end
    def []=(range, replacement)
      if @text.respond_to?(:[]=)
        @text[range] = replacement
      else
        @text = @text[0...range.min] + replacement + @text[range.max + 1..-1]
      end
    end
    def to_s
      @text
    end
  end

  class BMSChannelSentence
    attr_reader :line, :measure, :channel, :objects
    def initialize(line, measure, channel, data, data_index, resolver)
      @line     = line
      @measure  = measure
      @channel  = resolver ? resolver.resolve(measure, channel) : channel
      @objects  = parse_objects(data, data_index)
    end
    def parse_objects(data, data_index)
      i = 0
      objects = []
      total = (data.length / 2).floor
      (0...total).each do |n|
        i = n * 2
        value = data[i...i + 2]
        if value != '00'
          position = @measure.to_i(10) + divide(n, total)
          objects << BMSObject.new(line, data_index + i, position, self)
        end
      end
      objects
    end
    def divide(a, b)
      if b.respond_to?(:to_r)
        a / b.to_r
      else
        a / b.to_f
      end
    end
    def self.parse(line, resolver=nil)
      if line.text =~ /^\s*#(\d\d\d)(\d\d):(\S+)/
        match       = $~
        measure     = match[1]
        channel     = match[2]
        if channel != '02'
          data        = match[3]
          data_index  = line.text.index(':') + 1
          new(line, measure, channel, data, data_index, resolver)
        end
      end
    end
  end

  class BMSObject
    attr_reader :position, :sentence
    def initialize(line, index, position, sentence)
      @line = line
      @index = index
      @position = position
      @sentence = sentence
    end
    def value
      @line.text[@index...@index + 2]
    end
    def value=(new_value)
      @line[@index...@index + 2] = new_value
    end
    def channel
      @sentence.channel
    end
    def bgm?
      channel =~ /^b/
    end
    def ln?
      channel =~ /^[56]/
    end
  end

  module Logger
    def self.log(*args)
      if args.length == 1 && args[0].is_a?(String)
        $stderr.puts args[0]
      else
        $stderr.puts args.map(&:inspect).join(' ')
      end
    end
    def self.warn(position, message)
      log "WARNING at #{position.to_i}(#{position - position.to_i}): #{message}"
    end
  end

end

