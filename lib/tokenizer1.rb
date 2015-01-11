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


  def get_token
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
