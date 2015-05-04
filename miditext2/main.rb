
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'miditext'

Miditext::Processor.process!(ARGV[0])

