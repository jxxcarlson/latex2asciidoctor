
require_relative 'tokenizer'
require 'tree'
include Tree
require_relative 'counter'


class TexParser

 def initialize(text)

   @tk = Tokenizer.new(preprocess(text))
   @stack = []
   @counter = Counter.new

 end

  def preprocess(text)
    text = text.gsub('$', ' $ ')
    text = text.gsub('\\[', ' \\[ ')
    text.gsub('\\]', ' \\[ ')
  end

  def get_token
    @tk.get_token
  end

 def display_stack
   puts 'STACK:'.cyan
   @stack.each do |item|
     puts item
   end
   puts '---------------'.cyan
 end

 def push_stack(node)
   @stack.push node
 end

 def pop_stack
   @stack.pop
 end

 def top_stack
   @stack[-1]
 end

  def new_node(content)
    TreeNode.new(@counter.get, content)
  end

  def get_header
    @header = []
    token = get_token
    token_count = 0
    while token.value != '\\begin{document}' do
      @header << token
      token = get_token
      token_count += 1
    end
    @header << token
  end

  def display_token_list(token_list, option = :brief)
    token_list.each_with_index do |token, index|
      if option == :all
        puts "#{index}: ".blue + "#{token}"
      elsif option == :brief
        puts "#{index}: ".blue + "#{token.value}".cyan
      end
    end
  end

  def token_list_to_str(tokens)
    str = ''
    tokens.each do |token|
      if token.value == :blank_line
        str += "\n"
      elsif token.value.class.name == 'String'
        str += token.value + "\n"
      elsif token.value.class.name == 'Array'
        str += token.value.join(" ") + "\n"
      end
    end
    str
  end



end
