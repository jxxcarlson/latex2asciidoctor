require 'rspec'
require_relative '../lib/reader'


ROOT = '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end


describe Reader do

  it 'can read in a text file convert it to an array of lines' do

    text = IO.read(path('transcendence4.tex'))

    reader = Reader.new(text)

    expect(reader.valid).to eq true
    expect(reader.number_of_lines).to eq 661
    expect(reader.number_of_words).to eq 0
    expect(reader.current_word).to eq '@!START'

  end


  it 'can read in a text file convert it to an array of lines' do

    text = IO.read(path('simple.txt'))

    reader = Reader.new(text)

    expect(reader.valid).to eq true
    expect(reader.number_of_lines).to eq 4
    expect(reader.number_of_words).to eq 1

  end

  it 'can extracts the current and next line when initialized' do

    text = IO.read(path('simple.txt'))

    reader = Reader.new(text)

    expect(reader.valid).to eq true
    expect(reader.current_line).to eq 'one'
    expect(reader.next_line).to eq 'two three'

  end

  it 'can get lines on demand' do

    text = IO.read(path('simple.txt'))

    reader = Reader.new(text)

    expect(reader.valid).to eq true
    expect(reader.current_line).to eq 'one'
    expect(reader.get_line).to eq 'two three'
    expect(reader.get_line).to eq 'four five six'
    expect(reader.get_line).to eq 'seven eight nine ten'
    expect(reader.get_line).to eq nil

  end

  it 'can get look ahead to the next line' do

    text = IO.read(path('simple.txt'))

    reader = Reader.new(text)

    expect(reader.valid).to eq true
    expect(reader.current_line).to eq 'one'
    expect(reader.next_line).to eq 'two three'
    expect(reader.get_line).to eq 'two three'
    expect(reader.get_line).to eq 'four five six'
    expect(reader.next_line).to eq 'seven eight nine ten'
    expect(reader.get_line).to eq 'seven eight nine ten'
    expect(reader.next_line).to eq nil
    expect(reader.get_line).to eq nil

  end

  it 'can get words on demand in an edge case' do

    text = IO.read(path('simple3.txt'))

    reader = Reader.new(text)

    expect(reader.get_word).to eq 'one'
    expect(reader.get_word).to eq :end


  end

  it 'can get words on demand when the text is empty' do

    text = ''

    reader = Reader.new(text)

    expect(reader.valid).to eq false


  end


  it 'can get words on demand' do

    text = IO.read(path('simple2.txt'))

    reader = Reader.new(text)

    expect(reader.get_word).to eq 'one'
    expect(reader.get_word).to eq 'two'
    expect(reader.get_word).to eq 'three'
    expect(reader.get_word).to eq 'four'
    expect(reader.get_word).to eq 'five'
    expect(reader.get_word).to eq 'six'
    expect(reader.get_word).to eq :end

  end

  it 'maintains the relation @current_word a substring of @current_line' do

    text = IO.read(path('simple2.txt'))

    reader = Reader.new(text)

    expect(reader.get_word).to eq 'one'
    expect(reader.current_line =~ /#{reader.current_word}/).to be >= 0
    expect(reader.get_word).to eq 'two'
    expect(reader.current_line =~ /#{reader.current_word}/).to  be >= 0
    expect(reader.get_word).to eq 'three'
    expect(reader.current_line =~ /#{reader.current_word}/).to  be >= 0
    expect(reader.get_word).to eq 'four'
    expect(reader.current_line =~ /#{reader.current_word}/).to  be >= 0
    expect(reader.get_word).to eq 'five'
    expect(reader.current_line =~ /#{reader.current_word}/).to  be >= 0
    expect(reader.get_word).to eq 'six'
    expect(reader.current_line =~ /#{reader.current_word}/).to  be >= 0
    expect(reader.get_word).to eq :end

  end

  it 'can get all the words in the input' do

    text = IO.read(path('simple2.txt'))
    reader = Reader.new(text)
    last_word = reader.get_words(:verbose, 10)
    expect(last_word).to eq :end

  end

  it 'can get the next word of the input without changing @current_word' do
    text = IO.read(path('simple2.txt'))
    reader = Reader.new(text)
    expect(reader.get_word).to eq 'one'
    expect(reader.next_word).to eq 'two'
    expect(reader.get_word).to eq 'two'
    expect(reader.get_word).to eq 'three'
    expect(reader.next_word).to eq 'four'

  end


  it 'can advance the current line' do
    text = IO.read(path('simple2.txt'))
    reader = Reader.new(text)
    expect(reader.get_word).to eq 'one'
    reader.advance_line
    expect(reader.next_word).to eq 'four'


  end

=begin
  it 'can get all the words in the input' do

    text = IO.read(path('transcendence4.tex'))
    reader = Reader.new(text)
    last_word = reader.get_words(:verbose, 5000)
    expect(last_word  ).to eq :end

  end

=end


end
