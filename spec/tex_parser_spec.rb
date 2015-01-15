require 'rspec'
require_relative '../lib/tex_parser'


ROOT = '/Users/carlson/dev/git/latex2asciidoctor/text/'

def path file
  ROOT+file
end


describe TexParser do

=begin

  it 'can be initialized from a string' do

    text = IO.read(path('transcendence4.tex'))
    @tp = TexParser.new(text)
    @tp.get_token.value
    tval = @tp.get_token.value
    expect(tval).to eq ['\\documentclass[11pt]{amsart}']

  end

=end

  it 'can push nodes onto the stack' do

    tp = TexParser.new('')
    node = tp.new_node('one')
    tp.push_stack node
    node = tp.new_node('two')
    tp.push_stack node
    expect(tp.top_stack.content).to eq 'two'



  end


=begin

  it 'can be get the header of a tex file' do

    text = IO.read(path('transcendence4.tex'))
    @tp = TexParser.new(text)
    header = @tp.get_header
    # @tp.display_token_list header, :all
    header_str = @tp.token_list_to_str header
    puts header_str.yellow
    expect(header_str.length).to eq 1325
    puts @tp.get_token.value
    puts @tp.get_token.value
    puts @tp.get_token.value
    puts @tp.get_token.value


  end

=end

end
