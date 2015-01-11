require_relative 'reader'

class Token

  def initialize(type, value)
    @type = type
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


  def is_macro(str)
    str and str[0] == '\\'
  end

  def is_comment(str)
    str and str[0] == "%"
  end

  def match_begin_enviromment(str)
    rx = /\\begin{(.*)}/
    str.match rx
  end

  def is_begin_document(str)
    rx = /\\begin{document}/
    str =~ rx
  end


  def is_begin_environment(str)
    rx = /\\begin/
    rx = /\\begin{(.*)}/
    str =~ rx
  end


  def is_end_environment(str, environment)
    rx = /\\end/
    # rx = /\\end{#{environment}}/
    str =~ rx
  end

  def get_environment(word)
    env = [word]
    m = match_begin_enviromment(word)
    type = m[0]
    while !is_end_environment(word, type) and !word.nil?
      word = @reader.get_word
      env << word
    end
    env
  end

  def paren_count(str)
    left = str.scan /{/
    right = str.scan /}/
    left.count - right.count
  end

  def get_macro(str)
    macro = [str]
    cumulative_parent_count = paren_count(str)
    while cumulative_parent_count != 0 do
      word = @reader.get_word
      cumulative_parent_count += paren_count(word)
      macro << word
    end
    macro
  end



  def get_token
    str = @reader.get_word
    if is_comment(str)
      str  = @reader.current_line
      @reader.advance_line
     [:comment, @reader.line_index, @reader.word_index, str]
    elsif is_macro(str) and !is_begin_environment(str)
      [:macro, @reader.line_index, @reader.word_index, get_macro(str)]
    elsif is_begin_environment(str) and !is_begin_document(str)
      [:environment, @reader.line_index, @reader.word_index, get_environment(str)]
    elsif str != nil
     [:word, @reader.line_index, @reader.word_index, str]
    else
      :end
    end
  end

  def tokenize
    token = :start
    tokens = []
    until token == :end do
      token = get_token
      tokens << token
    end
    tokens
  end

end
