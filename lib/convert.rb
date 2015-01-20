require_relative '../lib/reader'
require_relative '../lib/parser'
require_relative '../lib/render_asciidoctor'
include RenderAsciidoctor

ROOT = File.expand_path File.dirname(__FILE__).gsub('spec', 'text')
ROOT = '/Users/carlson/dev/git/latex2asciidoctor'

def path file
  ROOT+"/"+file
end

text = IO.read(path(ARGV[0]))
parser = Parser.new(text)
parser.parse
rendered_text  = parser.top_stack.render_asciidoctor
puts rendered_text

