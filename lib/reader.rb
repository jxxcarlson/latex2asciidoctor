
require_relative 'core_ext'

BLANK_LINE = :end
EOL = "\n"
EOF = :end


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
  attr_accessor :lines

  def initialize(text, option = {})

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


    @words = @current_line.split(" ") << "\n"  # XXX (1)
    @number_of_words = @words.count
    @word_index = -1
    @current_word = '@!START'

  end

  ##############################################################
  #
  #   word methods: get_word, put_word, next_word, get_words
  #
  ##############################################################

  def get_word
    @word_index += 1
    if @word_index < @number_of_words
      @current_word = @words[@word_index]
    else
      @current_line = get_line
      if @current_line
        @words = @current_line.split(" ") << "\n"  # XXX (2)
        if @words.count == 0
          @current_word = EOL
        else
          @number_of_words = @words.count
          @word_index = 0
          @current_word = @words[@word_index]
        end
      else
        @current_word = :end
      end
    end
    @current_word
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

  def get_words(flag)
    word_count = 0
    while @current_word != :end
      get_word
      word_count += 1
      if flag == :verbose
        puts "#{word_count}: ".blue + "#{@current_word}".yellow
      end
    end
    @current_word
  end


  ##############################################################
  #
  #   line methods: get_line, next_line, previous_line
  #
  ##############################################################

  def get_line
    @line_index += 1
    if @line_index < @number_of_lines
      @current_line = (@lines[@line_index]).strip
      if @current_line
        @words = @current_line.split(" ") << "\n"  # XXX (3)
        @number_of_words = @words.count
        @word_index = 0
        @current_word = @words[@word_index]
      end
    else
      @current_line = nil
    end
    @current_line
  end


  def next_line
    next_line_index  = @line_index + 1
    if next_line_index < @number_of_lines
      @lines[next_line_index].strip
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


  ##############################################################
  #
  #   other methods: display
  #
  ##############################################################

  def display
    @lines.each_with_index do |line, index|
      puts "#{index + 1}".green + ": #{line}".blue
    end
  end



end
