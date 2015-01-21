module Test

  require 'rspec'
  require_relative '../lib/reader'
  require_relative '../lib/parser'


  case $RENDER_MODE
    when :asciidoctor
      require_relative '../lib/render_asciidoctor'
      include RenderAsciidoctor
      $TEST_MODE = :none
    else
      require_relative '../lib/render_identical'
      include RenderIdentical
      $TEST_MODE = :compressed
  end



  ROOT = File.expand_path File.dirname(__FILE__).gsub('lib', 'text')

  def path file
    ROOT+"/"+file
  end

  def bracket_log(arg, tag=nil)
    if tag
      puts "#{tag}: ".cyan + "[#{arg}]".red
    else
      puts "[#{arg}]".red
    end

  end



  def test(file, option = {})
    text = IO.read(path(file))

    parser = Parser.new(text)
    parser.parse

    if option[:verbose]
      puts "\n\nFile: ".blue + file.red
      parser.display_stack if option[:verbose]
      puts '-------------------------'.yellow
      puts "TREE:".red
      # parser.top_stack.print_tree
      if option[:verbose]
        puts "File: ".blue + file.red
        puts '-------------------------'.blue
        # puts text.cyan
        puts '-------------------------'.yellow
      end
      puts "File: ".blue + file.red
      puts '-------------------------'.yellow
    end

    expect(parser.token.value).to eq  'END_DOC'

    case $RENDER_MODE
      when :asciidoctor
        rendered_text  = parser.top_stack.render_asciidoctor
      else
        rendered_text  = parser.top_stack.render_identical
    end

    if option[:verbose]
      puts rendered_text.blue
      puts '-------------------------'.blue
    end

    case $TEST_MODE
      when :identical
        expect(rendered_text).to eq text
      when :compressed
        expect(rendered_text.compress).to eq text.compress
      else
        expect(1).to eq 1
    end

# text.gsub(/\\end{document}*/, '')
  end

end
