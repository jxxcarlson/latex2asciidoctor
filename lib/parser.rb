
require_relative 'reader'
require 'tree'
include Tree
require_relative 'counter'

BEGIN_DOC = '\begin{document}'
END_DOC = '\end{document}'


class Token

  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "#{type}: #{value}"
  end

end

class Parser

  attr_accessor :reader, :token, :stack

  def initialize(text)

    @reader = Reader.new(text)
    @stack = []
    @counter = Counter.new

  end

  def preprocess(text)
    text = text.gsub('$', ' $ ')
    text = text.gsub('\\[', ' \\[ ')
    text.gsub('\\]', ' \\[ ')
  end

  def get_token
    word = @reader.get_word
    if word[0] == '%'
      @token = Token.new(:comment, reader.current_line)
      reader.advance_line
    elsif word == :blank_line
      @token = Token.new(:blank, "\n")
      reader.advance_line
    else
      @token = Token.new(:word, word)
    end
    @token
  end

  def put_token
    @token = @reader.put_word
  end

  def display_node(node)
    name = node.name
    content = node.content
    puts name.to_s.red
    if content.class.name == 'Array'
      content.each do |element|
        puts element.to_s.cyan
      end
    else
      puts content.to_s.cyan
    end

  end

  def display_stack
    puts 'STACK:'.cyan
    @stack.each do |item|
      item_class_name = item.class.name
      if item_class_name == 'Token'
        puts token.value.to_s.cyan
      elsif item_class_name == 'Tree::TreeNode'
        display_node item
      end
    end
    puts '---------------'.cyan
  end

  def push_stack(node)
    @stack.push node
  end

  def pop_stack(count=1)
      @stack.pop(count)
  end

  def top_stack
    @stack[-1]
  end

  def new_node(content)
    TreeNode.new(@counter.get, content)
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

  # Grammar
  ################
  # PRODUCTIONS
  # document = header BEGIN_DOC body END_DOC
  # body = { text | macro | env }
  #
  # Terminals:
  # BEGIN_DOC = '\begin{document}'
  # END_DOC = '\end{document}'

  def header
    count = 0
    while @token.value != BEGIN_DOC
      get_token
      count += 1
      push_stack @token.value
    end
    header_value = pop_stack(count).join(' ').strip
    node = new_node([:header, header_value])
    push_stack node
    display_stack
  end

  def environment
    push_stack @token
    get_token
    count = 1
    while !(@token.value =~ /\A\\end/) do
      push_stack @token
      count += 1
      get_token
    end
    push_stack @token
    count += 1
    environment_list = pop_stack(count)
    node = new_node([:environment, environment_list])
    push_stack node
    display_stack
  end

  def text_sequence
    count = 1
    push_stack @token.value
    get_token
    while @token.value[0] != '\\'
      count += 1
      push_stack @token.value
      get_token
    end
    puts "text_sequence (1), @token = #{@token}".red
    if @token.value[0] == '\\'
      @reader.put_word
    end
    puts "text_sequence (2), @token = #{@token}".red
    str = pop_stack(count).join(' ')
    node = new_node([:text, str])
    push_stack node
    display_stack
  end

  def paren_count(str)
    left = str.scan /{/
    right = str.scan /}/
    left.count - right.count
  end

  def macro
    str = @token.value
    cumulative_parent_count = paren_count(str)
    while cumulative_parent_count != 0 do
      get_token
      value = @token.value
      cumulative_parent_count += paren_count(value)
      str << value
    end
    node = new_node([:macro, str])
    push_stack node
  end

  def body
    count = 0
    while @token.value != END_DOC
      get_token
      if @token.value =~ /\A\\begin/
        environment
      elsif @token.value =~ /\\/
        macro
      elsif @token.value[0] != '\\'
        text_sequence
      else
        count += 1
        push_stack @token.value
      end
    end
    body_list = pop_stack(count)
    node = new_node([:body, body_list])
    push_stack node
    display_stack
  end

  def parse
    get_token
    header
    if @token.value == BEGIN_DOC
      get_token
      body
      if @token.value != END_DOC
        error 'missing END_DOC'
      end
    else
      error 'missing BEGIN_DOC'
    end
  end



end
