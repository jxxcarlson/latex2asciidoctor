require_relative 'display'

module RenderIdentical

  # include Display


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
    name = self.attribute :env_type
    # "\\begin{#{name}}" << self.value.map{ |token| token.value }.string_join
    label = self.attribute :label
    if label
      label_text = "\n\\label{#{label}}"
    else
      label_text = ''
    end

    "\\begin{#{name}}" << label_text << self.value.map{ |node| node.render  }.string_join << "\\end{#{name}}"
  end

  def render_token
    self.value
  end

  def render_macro
    macro = self.attribute :macro
    # args = self.attribute :args
    case macro
      when 'item'
       "\n\\item #{self.value}\n"
      else
        self.default_render
    end
  end


  def render_node
    case self.type
      when :text, :comment, :end_document
        self.default_render
      when :body
        '\begin{document}' << "\n" << "\n"
      when :macro_defs
        render_macro_defs
      when :macro
        render_macro
      when :inline_math
        "#{self.value}" << "\n"
      when :display_math
        bracket_log "#{self.value}", 'DISPLAY_MATH'
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

  def render
    # Bad coding!  We shouldn't have to do this!!
    if self.class.name == 'Token'
      render_token
    else
      render_node
    end
  end

  def render_identical
    text = ''
    text << first_child.render_children # head
    text << last_child.render_children  # body
  end

  def render_lineage
    tip = self
    text = ''
    while tip  do
      text += tip.render
      tip = tip.first_child
    end
    text
  end

  def render_children
    text = ''
    self.children.each do |node|
      text << node.render
    end
    text
  end

  def render_macro_defs
    "%%begin_macro_defs\n" << self.value << "%%end_macro_defs\n"
  end




end

