require "log2changelog/version"
require "log2changelog/parser"

module Log2changelog

  class << self
    def read
      if File.pipe?(STDIN) || File.select([STDIN], [], [], 0) != nil then
        return STDIN.read
      end
      return ""
    end
  end

  parser = Parser.new(ARGV)
  lines = self.read
  if lines.length > 0
    puts parser.parse(lines)
    puts Time.now.to_s
  end

end

