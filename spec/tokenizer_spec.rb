require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/tokenizer'

ROOT = '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end

def get_tokens(tk, n)
  puts "begin tokenize (#{n})".red
  n.times do |index|
    puts "#{index + 1}: ".blue + "#{tk.get_token}".cyan
  end
  puts "end tokenize (#{n})".red
end


describe Tokenizer do


  it 'extracts tokens from text' do

    text = IO.read(path('1.tex'))
    tk = Tokenizer.new(text)

  end

  it 'recognizes the start of an environment' do

    text = "\\begin{foo} blah blah \\end{foo} "
    tk = Tokenizer.new(text)
    expect(tk.is_begin_environment(text)).to eq 0

  end


  it 'recognizes the end of an environment' do

    text = "\\begin{foo} blah blah \\end{foo} "
    tk = Tokenizer.new(text)
    expect(tk.is_end_environment(text, 'foo')).to be >= 0

  end

  it 'reads tokens from the document' do


    end


  it 'tokenizes a document by hand' do

    text = IO.read(path('1.tex'))
    tk = Tokenizer.new(text)
    get_tokens(tk, 7)



  end


  it 'tokenizes a document' do


    text = IO.read(path('1.tex'))
    tk = Tokenizer.new(text)

    tk.reader.display

    tk.tokenize.each_with_index do |token, index|
      puts "#{index + 1}: ".white + "#{token}".cyan
    end

  end


  it 'tokenizes a long document' do


    text = IO.read(path('transcendence4.tex'))
    tk = Tokenizer.new(text)

    tk.get_token.to_s.blue
    tk.get_token.to_s.blue
    tk.get_token.to_s.blue
    tk.get_token.to_s.blue
    tk.get_token.to_s.blue
    tk.get_token.to_s.blue



  end



end
