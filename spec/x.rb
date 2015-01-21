require 'rspec'
require_relative '../lib/test'
include Test


describe Parser do


  it 'can parse and render dificult stuff' do
    test('environment.tex', verbose: true)
  end


end
