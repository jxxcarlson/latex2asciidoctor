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

  def _get_token
    str = @reader.get_word
    if is_num(str)
      Token.new(:num, @reader.line_index, @reader.word_index, str)
    elsif is_alpha_num(str)
      Token.new(:alpha_num, @reader.line_index, @reader.word_index, str)
    elsif is_op(str)
      Token.new(:op, @reader.line_index, @reader.word_index, str)
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
#
# http://www.cis.upenn.edu/~matuszek/General/recursive-descent-parsing.
# http://en.wikipedia.org/wiki/Recursive_descent_parser
#

# :expr = :num | :num [+|-] :expr

class Parser

  attr_reader :value

  def initialize(text)
    @text = text
    @tk = Tokenizer.new(@text)
  end

  def get_token
    @tk.get_token
  end

  def push_token(token)
    @tk.push token
  end

  def error(message)
    puts "Error: #{message}".red
  end

  def expr
    value = 0
    token = get_token
    if token.type == :num
      value = token.value.to_i
      token = get_token
      if token.type == :op
        if token.value == '+'
          value = value + expr
        elsif token.value == '-'
          value = value - expr
        else
          error "unknown operation type (#{token.value}) in expr"
        end
      elsif token == :end
        error 'unexpected token in expr'
      end
    end
    value
  end


  def parse
   expr
  end

end
