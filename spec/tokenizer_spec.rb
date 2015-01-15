require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/tokenizer'

ROOT = '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end

def get_tokens(tk, n, option = :all)
  puts "begin tokenize (#{n})".red
  n.times do |index|
    @token = tk.get_token
    if option == :all
      puts "#{index + 1}: ".blue + "#{@token}".cyan
    elsif option == :brief
      if !([:word, :blank_liine].include? @token.type)
        puts "#{index + 1}: ".blue + "#{@token}".cyan
      end
    end
  end
  puts "end tokenize (#{n})".red
end


describe Tokenizer do

=begin

  it 'extract tokesn from a document' do

    text = IO.read(path('1.tex'))
    tk = Tokenizer.new(text)
    get_tokens(tk, 10)
    expect(@token.value).to eq :end

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

=end

  it 'tokenizes a document' do

    text = IO.read(path('1.tex'))
    tk = Tokenizer.new(text)
    tk.reader.display
    tokens = tk.tokenize
    expect(tokens[-1].value).to eq :end

    tokens.each_with_index do |token, index|
      puts "#{index + 1}: ".red + "#{token}".cyan
    end

  end



=begin
  it 'tokenizes a long document' do

    text = IO.read(path('transcendence4.tex'))
    tk = Tokenizer.new(text)
    # tk.reader.display
    tokens = tk.tokenize
    expect(tokens[-1].value).to eq :end
    puts "token count = #{tokens.count}".red
    expect(tokens.count).to be > 3000


  end


  it 'tokenizes a long document (2)' do

    text = IO.read(path('transcendence4.tex'))
    tk = Tokenizer.new(text)
    # tk.reader.display
    get_tokens(tk, 3040, :brief)
    expect(@token.value).to eq :end

  end

=end

end
