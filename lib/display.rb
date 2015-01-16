
module Display

  ############################################
  #
  # The next five methods display the stack
  # or elements on it, or display tokens.
  #
  ############################################


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

  def display_tree(node)
    tip = node
    level = 0
    while tip do
      display_element tip, level
      level += 1
      tip = tip.first_child
    end
  end

  def render_node(node)
    content = node.content
    type = content[:type]
    case type
      when :header
        content[:text] << "\n"
      when :macro
        content[:value]
      when :body
        '\begin{document}' << "\n"
      when :text, :comment, :end_document
        content[:value] << "\n"
      when :display_math
        "\\[#{content[:value]}\\]" << "\n"
      else
        "\n" << node.name
    end
  end

  def render_tree(node=top_stack)
    tip = node
    text = ""
    while tip do
      text += render_node tip
      tip = tip.first_child
    end
    text
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

  ######################################



end
