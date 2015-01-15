
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

    @reader = Reader.new(preprocess(text))
    @stack = []
    @counter = Counter.new

  end

  def preprocess(text)
    text = text.gsub('$', ' $ ')
    text = text.gsub('\\[', ' \\[ ')
    text.gsub('\\]', ' \\] ')
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


  def display_element(element, level)
    class_name = element.class.name
    if level > 0
      prefix = " "*level*2 + "#{level}: "
      pprefix = " "*level*2
    else
      prefix = ""
    end
    case class_name
      when 'Symbol'
        puts "#{pprefix}symbol: #{element}".blue
      when 'String'
        puts "#{pprefix}string: #{element}".blue
      when 'Token'
        puts "#{pprefix}token: #{element.type}: #{element.value}".blue
      when 'Array'
        puts "#{prefix}-------------------------".blue
        puts "#{prefix}Array :".red
        element.each do |item|
          display_element item, level + 1
        end
        puts "#{prefix}- - - - - - - - - - - - - ".blue
      when 'Hash'
        puts "#{prefix}-------------------------".blue
        puts "#{prefix}Hash :".red
        element.each do |key, value|
          puts "#{pprefix}#{key.to_s}".red
          display_element value, level + 1
        end
        puts "#{prefix}- - - - - - - - - - - - - ".blue
      when 'Tree::TreeNode'
        puts "#{prefix}++++++++++++++++".cyan
        puts "#{pprefix}node: #{element.name}".red
        display_element element.content, level + 1
        puts "#{prefix}+ + + + + + + + ".cyan
      else
        puts "#{prefix}unknown:".magenta
        puts element
    end
  end


  def display_stack
    puts 'STACK:'.cyan
    @stack.each do |item|
      display_element item, 0
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
  # body = { expr }
  # expr = { text | macro | env | inline_math | display_math }
  # macro = \command \{ {args} \}
  # env = BEGIN_ENV expr END_ENV
  # inline_math = $ math_text #
  # display_math = \[ math_text \]
  #
  #
  # Terminals:
  # BEGIN_DOC = '\begin{document}'
  # END_DOC = '\end{document}'
  # Pseutotermnals
  # BEGIN_ENV = '\begin{' env_name '}'
  # END_ENV = '\end{' env_name '}'

  def header
    count = 0
    while @token.value != BEGIN_DOC
      get_token
      count += 1
      push_stack @token.value
    end
    pop_stack # remove \begin{document}
    header_value = pop_stack(count).join(' ').strip
    node = new_node({type: :header, value: header_value})
    push_stack node
  end


  def environment(end_token)
    rx = /\\end{(.*)}/
    env_type = (end_token.match rx)[1]
    push_stack @token
    get_token
    count = 1
    while @token.value != end_token do
      push_stack @token
      count += 1
      get_token
    end
    push_stack @token
    count += 1
    environment_list = pop_stack(count)
    node = new_node({type: :environment, env_type: "#{env_type}", value: environment_list})
    push_stack node
  end

  def text_sequence
    count = 1
    push_stack @token.value
    get_token
    while @token.value != '$' and @token.value[0] != '\\'
      count += 1
      push_stack @token.value
      get_token
    end
    if @token.value == '$' or @token.value[0] == '\\'
      @reader.put_word
    end
    str = pop_stack(count).join(' ')
    node = new_node({type: :text, value: str})
    push_stack node
  end

  def inline_math
    get_token
    count = 1
    push_stack @token.value

    while @token.value != '$'
      count += 1
      push_stack @token.value
      get_token
    end
    if @token.value == '$'
      # push_stack @token.value
      get_token
    end
    str = pop_stack(count).join(' ')
    node = new_node({type: :inline_math, value: str})
    push_stack node
  end

  def display_math
    get_token
    count = 1
    push_stack @token.value
    puts @token.value.to_s.magenta
    while @token.value != '\\]'
      puts @token.value.to_s.magenta
      count += 1
      push_stack @token.value
      get_token
    end
    if @token.value == '\\]'
      get_token
    end
    str = pop_stack(count).join(' ')
    node = new_node({type: :display_math, value: str})
    push_stack node
    # display_stack
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
    name_rx =/\\([a-zA-Z].*?){/
    args_rx = /{(.*)}/
    command_name = (str.match name_rx)[1].strip
    arg_str = (str.match args_rx)[1]
    puts "arg_str: #{arg_str}".magenta
    args = arg_str.split(',').map{ |x| x.strip}
    puts "args: #{args}".magenta
    node = new_node({type: :macro, value: str, macro: command_name, args: args})
    push_stack node
  end



  def expr
    if @token.value =~ /\A\\begin/
      begin_token = @token.value
      end_token = begin_token.gsub('begin', 'end')
      environment(end_token)
    elsif @token.value == '$'
      inline_math
    elsif @token.value == '\\['
      display_math
    elsif @token.value =~ /\\[a-zA-Z].*/
      macro
    elsif @token.value[0] != '\\'
      text_sequence
    else
      push_stack @token.value
    end
  end

  def body
    count = 0
    while @token.value != END_DOC
      get_token
      expr
      count += 1
    end
    body_list = pop_stack(count)
    node = new_node({type: :body, value: body_list})
    push_stack node
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
