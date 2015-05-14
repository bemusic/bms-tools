
require 'opal'
require 'keysounder'

class FakeStderr
  attr_reader :out
  def initialize
    @out = []
  end
  def puts(*args)
    @out.push(*args)
  end
end

module JSBMSCompiler
  def self.compile(str, filename)
    old_stderr = $stderr
    $stderr = FakeStderr.new
    x = BMSCompiler::Keysounder.new(str)
    x.process!
    target_filename = filename ? BMSCompiler::Compiler.get_target_filename(filename) : nil
    return [$stderr.out, x.output, target_filename]
  ensure
    $stderr = old_stderr
  end
end

`
var BMSCompiler = {
  compile: function(str, filename) {
    return #{JSBMSCompiler.compile(`str`, `filename`)}
  }
}
onmessage = function(e) {
  var result = BMSCompiler.compile(e.data.bms, e.data.filename)
  postMessage({
    messages: result[0],
    bms: result[1],
    filename: result[2],
  })
}
`


