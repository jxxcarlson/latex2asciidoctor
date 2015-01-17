

class Tree::TreeNode


  def basic_render
    content = self.content
    content[:value]
  end

  def render_environment
    content = self.content
    content[:value].map{ |token| token.value }.string_join
  end


  def render
    content = self.content
    type = content[:type]
    case type
      when :header, :text, :comment, :macro, :comment, :end_document
        self.basic_render
      when :body
        '\begin{document}' << "\n" << "\n"
      when :inline_math
        "#{content[:value]}" << "\n"
      when :display_math
        "\\[#{content[:value]}\\]" << "\n"
      when :environment
        self.render_environment
      else
        puts "FUNNY NODE, #{node.name}".magenta
        display_node node
        puts "======== end funny =========".magenta
        "\n" << node.name
    end
  end

  def render_tree
    tip = self
    text = ""
    while tip do
      text += tip.render
      tip = tip.first_child
    end
    text
  end

end
