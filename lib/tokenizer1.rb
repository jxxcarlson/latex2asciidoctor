require_relative 'reader'

class Token

  attr_reader :type, :line_index, :word_index, :value

  def initialize(type, line_index, word_index, value)
    @type = type
    @line_index = line_index
    @word_index = word_index
    @value = value
  end

  def to_s
    "#{@type}: #{@value}"
  end

end

class Tokenizer

  attr_reader :text, :reader

  def initialize(text)
    @text = text
    @reader = Reader.new(@text)
    @stack = []
  end


  def is_num(str)
   str =~ /[1-9][0-9]*/
  end

  def is_alpha_num(str)
    str =~ /[a-zA-Z][a-zA-Z0-9]*/
  end

  def is_op(str)
    %w(+ - * /).include? str
  end

  def is_paren(str)
    %w(( )).include? str
  end

  def _get_token
    str = @reader.get_word
    if is_num(str)
      Token.new(:num, @reader.line_index, @reader.word_index, str)
    elsif is_alpha_num(str)
      Token.new(:alpha_num, @reader.line_index, @reader.word_index, str)
    elsif is_op(str)
      Token.new(:op, @reader.line_index, @reader.word_index, str)
    elsif is_paren(str)
      Token.new(:paren, @reader.line_index, @reader.word_index, str)
    else
      :end
    end
  end

  def get_token
    if !stack_empty?
      pop
    else
      _get_token
    end
  end

  def pop
    @stack.pop
  end

  def push(token)
    @stack.push token
  end

  def stack_empty?
    @stack.count == 0
  end


  def tokenize
    token = Token.new(:start, 0, 0, 'start')
    tokens = []
    until token.value == :end do
      token = get_token
      tokens << token
    end
    tokens
  end

end

# Grammar
# http://stackoverflow.com/questions/9814528/recursive-descent-parser-implementation << GOOD
# http://www.cis.upenn.edu/~matuszek/General/recursive-descent-parsing.html
# http://en.wikipedia.org/wiki/Recursive_descent_parser
#

# :expr => [-] :term { (+|-) :term }
# :term => :factor { (*|/) :factor }
# :factor => :number | ( expr )

class Parser

  attr_reader :token

  def initialize(text)
    @text = text
    @tk = Tokenizer.new(@text)
    @total_tokens_consumed  = 0
  end

  def get_token
    @token = @tk.get_token
    puts "get : #{@token}".red
    @token
  end

  def push_token
    @tk.push token
    if token.class.name == 'Array'
      print_token = token[0]
    else
      print_token = token
    end
    puts "put : #{print_token}".red
  end

  def error(message)
    puts "Error: #{message}".red
  end

  def is_number
    @token.type == :num
  end

  def is_minus_op
    @token.type == :op and @token.value == '-'
  end

  def is_plus_op
    @token.type == :op and @token.value == '+'
  end

  def is_additive_op
    @token.type == :op and @token.value =~ /-|\+/
  end

  def is_mul_op
    @token.type == :op and @token.value == '*'
  end

  def is_div_op
    @token.type == :op and @token.value == '/'
  end

  def is_multiplicative_op
    @token.type == :op and @token.value =~ /\*|\//
  end

  def is_left_paren
    @token.type == :paren and @token.value == '('
  end

  def is_right_paren
    @token.type == :paren and @token.value == ')'
  end


  def factor
    if is_number
      get_token
    end
    if is_left_paren
      get_token
      expr
      get_token
    end
  end

  def term
    factor
    while is_multiplicative_op
      get_token
      factor
    end
  end

  def expr
   if is_minus_op
     get_token
     term
   else
     term
   end
    while is_additive_op do
      get_token
      term
    end
  end


  def parse
   get_token
   expr
  end

end
