require_relative 'lib/reader'



text = IO.read(ARGV[0])

reader = Reader.new(text)

puts "#{reader.lines.count} lines read"
