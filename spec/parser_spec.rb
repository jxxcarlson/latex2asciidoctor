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

    text = IO.read(path('0.tex'))
    puts text.cyan
    parser = Parser.new(text)
    parser.reader.display

    puts parser.get_token.value
    puts parser.get_token.value
    puts parser.get_token.value
    puts parser.get_token.value
    puts parser.get_token.value
    puts parser.get_token.value


  end



  it 'can get tokens from a file' do

    text = IO.read(path('1  .tex'))
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

  it 'can display element of the stack' do

    parser = Parser.new('')

    str = "foo bar"
    parser.display_element str

    symbol = :foo
    parser.display_element symbol

    token = Token.new(:yuuk, 'more')
    parser.display_element token

    node = parser.new_node('hoho')
    parser.display_element node

    node2 = parser.new_node([1, 2, 3])
    parser.display_element node2

    array = [str, symbol, token, node, node2]
    parser.display_element array



  end





=end


  it 'can recognize a valid file' do

    text = IO.read(path('0.tex'))
    puts text.cyan
    
    parser = Parser.new(text)
    parser.parse
    expect(parser.token.value).to eq  END_DOC

    puts
    puts "parser.stack.count: #{parser.stack.count}".yellow
    parser.display_stack

  end






end
