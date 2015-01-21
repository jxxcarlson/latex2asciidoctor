require_relative 'display'


module RenderAsciidoctor


  def render_signal(text)
    puts text.red if $VERBOSE
  end

  def default_render
    render_signal('default_render')
    if self.value.class.name == 'String'
      self.value
    else
      "oops (type = #{self.type}) "
    end
  end

  def render_tex_environment
    render_signal('render_tex_environment')
    env_name = self.attribute :env_type
    value = "\\begin{#{env_name}}"
    value << self.value.map{ |node| node.render  }.string_join
    value << "\\end{#{env_name}}"
  end

  def render_asciidoc_environment
    render_signal('render_asciidoc_environment')
    env_name = self.attribute :env_type
    label = self.attribute :label
    if label
      label_text = "\##{label}"
    else
      label_text = ''
    end
    value = "\n[env.#{env_name}#{label_text}]\n--"

    value << self.value.map{ |node| node.render  }.string_join << "--\n"
  end

  def render_environment
    render_signal('render_environment')
    env_name = self.attribute :env_type
    puts "env_name: ".red + "#{env_name}".cyan
    if ['array', 'array*', 'matrix', 'matrix*', 'align', 'align*'].include? env_name
      render_tex_environment
    else
      render_asciidoc_environment
    end
  end

  def render_display_math
    value = ""
    self.value.each do |element|
      if element.class.name == 'Node'
        value  << element.render
      else
        value << element
      end
    end
    value
  end


  def render_macro
    render_signal('render_macro')
   macro = self.attribute :macro
   args = self.attribute :args
   case macro
     when 'section'
       "== #{args[0]}\n"
     when 'subsection'
       "=== #{args[0]}\n"
     when 'subsubsection'
       "==== #{args[0]}\n"
     when 'heading' ## IS THIS CORRECT (XX)
       "===== #{args[0]}\n"
     when 'subheading' ## IS THIS CORRECT (XX)
       "====== #{args[0]}\n"
     when 'item'
       "\n. #{self.value}\n"
     else
       "\n////\n" << self.default_render << "\n////\n"
   end

  end

  def render
    render_signal('render')
    class_name  =  self.class.name
    case class_name
      when 'Node'
        self.render_node
      when 'Token'
        self.value
      when 'String'
        self
      else
        self.to_s
    end
  end


  def render_node
    # puts "render #{self.type}: #{self.value}".yellow
    case self.type
      when  :text
        default_render
      when :header
        ''
      when :body
        ''
      when :end_document
        ''
      when :comment
        "////\n" << self.value << "////\n"
      when :macro
        render_macro
      when :macro_defs
        render_macro_defs
      when :inline_math
        " #{self.value} "
      when :display_math
        render_signal('render_display_math')
        render_display_math
      when :environment
        render_environment
      when :new_line
        "\\\\"
      else
        puts "FUNNY NODE, #{node.name}".magenta
        display_node node
        puts "======== end funny =========".magenta
        "\n" << node.name
    end
  end

  def postprocess(text)
    text = text.gsub('{', '{ ')
    text.gsub('}', ' }')
  end

  def render_asciidoctor
    text = ''
    text << first_child.render_children # head
    text << last_child.render_children  # body
    postprocess(text)
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
    "++++\n" << "\\(\n" << self.value << "\\)\n" << "++++\n"
  end


end

