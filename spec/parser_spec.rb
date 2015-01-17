require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/parser'

ROOT = File.expand_path File.dirname(__FILE__).gsub('spec', 'text')

def path file
  ROOT+"/"+file
end



def test(file, option = {})
  text = IO.read(path(file))
  if option[:verbose]
    puts "\n\nFile: ".blue + file.red
    puts '-------------------------'.blue
    puts text.cyan
    puts '-------------------------'.yellow
  end
  parser = Parser.new(text)
  parser.parse
  puts "TEXT PARSED".red if option[:verbose]
  expect(parser.token.value).to eq  END_DOC
  rendered_text = parser.render_tree
  if option[:verbose]
    puts rendered_text.blue
    puts '-------------------------'.blue
  end
  if option[:strict]
    expect(rendered_text).to eq text
  else
    expect(rendered_text.compress).to eq text.compress
  end

end

describe Parser do


  it 'can get a token from a file' do

    text = IO.read(path('hello.tex'))
    parser = Parser.new(text)
    # parser.reader.display
    expect(parser.get_token.value).to eq 'hello'

  end


  it 'can get all the token from a file' do

    text = IO.read(path('comment.tex'))
    parser = Parser.new(text)
    if $VERBOSE
      puts text.cyan
      puts '-----------------------------'.cyan
      puts '        TOKENS:              '.yellow
      puts '-----------------------------'.cyan
    end
    token = Token.new(:start, 'start')
    count = 0
    while token.type != :end
      count += 1
      parser.get_token
      token = parser.token
      puts "#{count}: #{token}".yellow if $VERBOSE
    end
    expect(token.type).to eq :end

  end


  it 'can parse and render an empty tex document' do
    test('empty.tex')
  end


  it 'can parse and render paragraphs' do
    test('paragraphs.tex')
  end


  it 'can parse and render comments' do
    test('comment.tex')
  end

  it 'can parse and render macros' do
    test('macro.tex')
  end

  it 'can parse and render environments' do
    test('environment.tex')
  end

  it 'can parse and render in-line math' do
    test('inline_math.tex')
  end

  it 'can parse and render display math' do
    test('display_math.tex', verbose: true)
  end


end
