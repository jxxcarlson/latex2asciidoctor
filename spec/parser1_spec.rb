require 'rspec'
require_relative '../lib/reader'
require_relative '../lib/tokenizer1'
                                                                                                                                                  '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end


describe Reader do

  it 'can read a program' do
    program = '15 + 7'
    reader = Reader.new(program)
    expect(reader.get_word).to eq '15'
    expect(reader.get_word).to eq '+'
    expect(reader.get_word).to eq '7'
    expect(reader.get_word).to eq :end
  end

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
