require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/parser'

ROOT = '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end

describe Parser do

=begin

  it 'can get tokens from a file' do

    text = IO.read(path('1.tex'))
    puts text.cyan
    parser = Parser.new(text)
    parser.reader.display
    expect(parser.get_token.value).to eq '%% This is a test file'
    expect(parser.get_token.value).to eq :blank_line
    expect(parser.get_token.value).to eq '\begin{document}'
    expect(parser.get_token.value).to eq :blank_line
    expect(parser.get_token.value).to eq '\newcommand{\DT}{{\mathbb'
    expect(parser.get_token.value).to eq  'S}}'

  end

=end

  it 'can recognize a valid file' do

    text = IO.read(path('1.tex'))
    puts text.cyan
    parser = Parser.new(text)
    parser.parse
    expect(parser.token.value).to eq  END_DOC

    puts
    puts "parser.stack.count: #{parser.stack.count}".yellow

    item =  parser.stack[0]
    puts item.class.name.yellow
    puts item.content

    item =  parser.stack[1]
    puts item.class.name.yellow
    puts item

    item =  parser.stack[2]
    puts item.class.name.yellow
    puts item.content

  end




end
