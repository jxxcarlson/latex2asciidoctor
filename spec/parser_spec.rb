require 'rspec'
require_relative '../lib/test'
include Test

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


  it 'can pop tokens from the stack to a list' do

    text = 'one two three'
    parser = Parser.new text

    token = parser.get_token
    parser.push_stack token
    token = parser.get_token
    parser.push_stack token
    list = parser.pop_stack_to_list(2)
    expect(list.map{ |x| x.value}).to eq ['one', 'two']


  end

  it 'can push tokens onto the token stack and later get them back (1)' do

    text = 'one two three'
    parser = Parser.new text

    token = parser.get_token
    expect(token.value).to eq 'one'
    parser.push_stack token

    parser.push_tokens(1)
    expect(parser.token_stack.count).to eq 1

    token = parser.get_token
    expect(token.value).to eq 'one'
    token = parser.get_token
    expect(token.value).to eq 'two'


  end

  it 'can push tokens onto the token stack and later get them back (2)' do

    text = 'one two three'
    parser = Parser.new text

    token = parser.get_token
    expect(token.value).to eq 'one'
    parser.push_stack token

    token = parser.get_token
    expect(token.value).to eq 'two'
    parser.push_stack token

    parser.push_tokens(2)
    expect(parser.token_stack.count).to eq 2

    token = parser.get_token
    expect(token.value).to eq 'one'
    token = parser.get_token
    expect(token.value).to eq 'two'

  end

  it 'can parse and render an empty tex document' do
    test('empty.tex', verbose: false)
  end

  it 'can parse and render paragraphs' do
    test('paragraphs.tex', verbose: false)
  end

  it 'can parse and render comments' do
    test('comment.tex', verbose: false)
  end

  it 'can parse and render macros' do
    test('macro.tex', verbose: false)
  end

  it 'can parse and render environments' do
    test('environment.tex', verbose: false)
  end

  it 'can parse and render in-line math' do
    test('inline_math.tex', verbose: false)
  end

  it 'can parse and render display math' do
    test('display_math.tex', verbose: false)
  end

  it 'can parse and render an itemized list' do
    test('itemize.tex', verbose: false)
  end

  it 'can parse and render the matrix environment inside display math' do
    test('matrix.tex', verbose: false)
  end

  it 'can parse and render an equation alignment inside display math' do
    test('align.tex', verbose: false)
  end

=begin

    it 'can parse and render a real tex document' do
    test('transcendence1.tex', verbose: false)
  end



  it 'can parse and render a real tex document' do
    # test('renzo_plan.tex', verbose: true)
  end

  it 'can parse and render a real tex document' do
    # test('renzo.tex', verbose: true)
  end

=end

end
