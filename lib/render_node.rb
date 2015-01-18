require_relative 'display'


module RenderNode

  include Display


  def default_render
    if self.value.class.name == 'String'
      self.value
    else
      "oops (type = #{self.type}) "
    end
  end


  def basic_render
    class_name = self.value.class.name
    if class_name == 'String'
      self.value
    else
      'BASIC_RENDER: NIL'
    end
  end

  def render_environment
    self.value.map{ |token| token.value }.string_join
  end


  def render
    case self.type
      when :header, :text, :comment, :macro, :comment, :end_document
        self.default_render
      when :body
        '\begin{document}' << "\n" << "\n"
      when :inline_math
        "#{self.value}" << "\n"
      when :display_math
        "\\[#{self.value}\\]" << "\n"
      when :environment
        self.render_environment
      else
        puts "FUNNY NODE, #{node.name}".magenta
        display_node node
        puts "======== end funny =========".magenta
        "\n" << node.name
    end
  end

  def render_tree0
    self.print_tree
  end

  def render_tree
    tip = self
    text = ''
    while tip  do
      text += tip.render
      tip = tip.first_child
    end
    text
  end


end

