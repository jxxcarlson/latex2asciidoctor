require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/tokenizer1'
                                                                                                                                                  '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end


describe Reader do

  it 'can read a program' do
    program = '( 15 + 7 )'
    reader = Reader.new(program)
    expect(reader.get_word).to eq '('
    expect(reader.get_word).to eq '15'
    expect(reader.get_word).to eq '+'
    expect(reader.get_word).to eq '7'
    expect(reader.get_word).to eq ')'
    expect(reader.get_word).to eq :end
  end


end

describe Tokenizer do

  it 'can tokenize a program' do
    program = '15 + 7'
    tk = Tokenizer.new(program)

    token = tk.get_token
    expect(token.value).to eq '15'
    expect(token.type).to eq :num

    token = tk.get_token
    expect(token.value).to eq '+'
    expect(token.type).to eq :op

    token = tk.get_token
    expect(token.value).to eq '7'
    expect(token.type).to eq :num

    token = tk.get_token
    expect(token.value).to eq :end

  end

  it 'can get parentheses' do

    program = '('
    tk = Tokenizer.new(program)

    token = tk.get_token
    expect(token.value).to eq '('


  end

  it 'can push and pop tokens' do
    program = '15 + 7'
    tk = Tokenizer.new(program)

    token = tk.get_token
    expect(token.value).to eq '15'
    expect(token.type).to eq :num

    tk.push token

    token = tk.get_token
    expect(token.value).to eq '15'
    expect(token.type).to eq :num

    token = tk.get_token
    expect(token.value).to eq '+'
    expect(token.type).to eq :op
    token1 = token

    token = tk.get_token
    expect(token.value).to eq '7'
    expect(token.type).to eq :num
    token2 = token

    tk.push token2
    tk.push token1

    token = tk.get_token
    expect(token.value).to eq '+'
    expect(token.type).to eq :op

    token = tk.get_token
    expect(token.value).to eq '7'
    expect(token.type).to eq :num



    token = tk.get_token
    expect(token.value).to eq :end

  end

  it 'can tokenize a program and halt' do
    program = '15 + 7'
    tk = Tokenizer.new(program)

    tokens = tk.tokenize

    expect(tokens.count).to eq 4

    token = tokens[0]
    expect(token.value).to eq '15'
    expect(token.type).to eq :num

    token = tokens[1]
    expect(token.value).to eq '+'
    expect(token.type).to eq :op

    token = tokens[2]
    expect(token.value).to eq '7'
    expect(token.type).to eq :num

    token = tokens[3]
    expect(token.value).to eq :end

  end

end

describe Parser do



  it 'can get tokens and recognize the expression 17' do
    puts "\n\nPROGRAM: 17".cyan
    p = Parser.new('17')
    expect(p.get_token.value).to eq '17'
    expect(p.get_token.value).to eq :end

  end

  it 'can recognize the expression "- 17"' do
    puts "\n\nPROGRAM: - 17".cyan
    p = Parser.new('- 17')
    p.parse
    expect(p.token.value).to eq :end

  end

  it 'can evaluate the expression "1 + 2"' do
    puts "\n\nPROGRAM: 1 + 2".cyan
    p = Parser.new('1 + 2')
    p.parse
    expect(p.token.value).to eq :end

  end


  it 'can recognize the expression "2 * 3"' do
    puts "\n\nPROGRAM: 2 * 3".cyan
    p = Parser.new('2 * 3')
    p.parse
    expect(p.token.value).to eq :end

  end


  it 'can recognize the expression "( 2 + 3 ) * ( 4 + 5 )"' do
    puts "\n\nPROGRAM: ( 2 + 3 ) * ( 4 + 5 )".cyan
    p = Parser.new("( 2 + 3 ) * ( 4 + 5 )")
    p.parse
    expect(p.token.value).to eq :end


  end



end
