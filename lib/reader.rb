
require_relative 'core_ext'


# The Reader is initialized with a text string.  It creates
# two arrays from the input tex, @lines and @words.
# The method Reader # get_words retrieves words from the text.
# and sets @current_word to that word. The @curent word is
# always a substring of the @current_line
#
class Reader

  attr_reader :number_of_lines, :number_of_words
  attr_reader :current_line, :current_word
  attr_reader :line_index, :word_index
  attr_reader :valid

  def initialize(text)


    @valid = false

    if text
      @text = text
    else
      return @valid
    end


    @lines = text.split("\n")
    @lines2 = @lines.select{ |line| line.length > 0}
    @line_index = 0
    @number_of_lines = @lines.count
    @current_line = @lines[@line_index]

    if current_line.nil?
      return @valid
    else
      @valid = true
    end


    @words = @current_line.split(" ")
    @number_of_words = @words.count
    @word_index = -1
    @current_word = '@!START'

  end

  def advance_word
    @current_word = get_word
  end

  def get_word
    @word_index += 1
    if @word_index < @number_of_words
      @current_word = @words[@word_index]
    else
      if @current_line = get_line
        @current_word
      else
        :end
      end
    end
  end

  def put_word
    @word_index -= 1
    if @word_index >= 0
      @current_word = @words[@word_index]
    else
      if @current_line = previous_line
        words_in_line = @current_line.split(' ')
        @current_word = words_in_line[-1]
      else
        :end
      end
    end
  end

  def next_word
    if @word_index + 1< @number_of_words
      @next_word = @words[@word_index + 1]
    else
      if @next_line = next_line
        words_in_nex_line = @next_line.split(' ')
        if words_in_nex_line
          words_in_nex_line[0]
        else
          nil
        end
      else
        :end
      end
    end
  end

  def parse_line(line, start_index = 0)
    @words = line.split(' ')
    @number_of_words = @words.count
    @word_index = start_index
    if @word_index < @number_of_words
      @current_word = @words[@word_index]
      # puts "NIL (3)".red if @current_word.nil? # XX
      @current_word
    else
      @current_word = :blank_line
    end
  end

  def get_line(word_index = 0)
    @line_index += 1
    if @line_index < @number_of_lines
      line = @lines[@line_index]
      parse_line(line, word_index)
    else
      @current_word = :end
      line = nil
    end
    line
  end

  def advance_line
    @current_line = get_line(-1)
  end

  def next_line
    next_line_index  = @line_index + 1
    if next_line_index < @number_of_lines
      @lines[next_line_index]
    else
      nil
    end
  end

  def previous_line
    previous_line_index  = @line_index -+ 1
    if previous_line_index >= 0
      @lines[previous_line_index]
    else
      nil
    end
  end


  def display
    @lines.each_with_index do |line, index|
      puts "#{index + 1}".green + ": #{line}".blue
    end
  end

  def get_words(flag, limit)
    word_count = 0
    while @current_word != :end and word_count < limit
      get_word
      word_count += 1
      if flag == :verbose
        puts "#{word_count}: ".blue + "#{@current_word}".cyan
      end
    end
    @current_word
  end


end
