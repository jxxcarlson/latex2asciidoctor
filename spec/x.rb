require 'rspec'
require_relative '../lib/test'
include Test

# $TEST_MODE   : [:compressed, :identical, :none]
# $RENDER_MODE : [:asciidoctor, :identical]

# $RENDER_MODE = :asciidoctor

describe Parser do

  it 'can parse and render dificult stuff' do
    test('display_math.tex', verbose: true)
  end


end
