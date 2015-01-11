
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


    # puts "#{@number_of_lines} lines".blue
    # puts "#{@number_of_words} words".cyan
    # puts "first word: ".blue + "#{@current_word}".red
    # puts "first line: ".blue + "#{@current_line}".red


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
        nil
      end
    end

  end

  def parse_line(line, start_index = 0)
    @words = line.split(' ')
    @number_of_words = @words.count
    @word_index = start_index
    @current_word = @words[@word_index]
  end

  def get_line(word_index = 0)
    @line_index += 1
    if @line_index < @number_of_lines
      line = @lines[@line_index]
      parse_line(line, word_index)
    else
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

  def get_line_old
    value = @next_line
    # Update state (@current_line, @next_line)
    if @next_line
      @current_line = @next_line
      @line_index += 1
      if @line_index + 1 < @number_of_lines
        @next_line = @lines[@line_index + 1]
      else
        @next_line = nil
      end
    else
      @current_line = nil
    end
    value
  end

  def display
    @lines.each_with_index do |line, index|
      puts "#{index + 1}".green + ": #{line}".blue
    end
  end


end
