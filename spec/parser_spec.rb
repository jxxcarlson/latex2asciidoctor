require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/parser'

ROOT = File.expand_path File.dirname(__FILE__).gsub('spec', 'text')

def path file
  ROOT+"/"+file
end

def compress(str)
  str.gsub(/ |\n/, '')
end

describe Parser do


  it 'can get tokens from a file' do

    text = IO.read(path('1.tex'))
    parser = Parser.new(text)
    # parser.reader.display
    expect(parser.get_token.value).to eq '%% This is a test file'

  end




  it 'can recognize 0.tex as a valid file' do

    text = IO.read(path('0.tex'))
    parser = Parser.new(text)
    parser.parse
    expect(parser.token.value).to eq  END_DOC
    rendered_text = parser.render_tree

    puts "render_tree:".red
    puts parser.render_tree

    expect(compress(rendered_text)).to eq compress(text)


  end






end
