
require_relative 'tokenizer'

class TexParser

 def initialize(text)

   @tk = Tokenizer.new(text)

 end

  def get_token
    @tk.get_token
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
