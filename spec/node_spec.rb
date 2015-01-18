require 'rspec'
require_relative '../lib/node'

describe Node do

  it 'can create nodes with names supplied by @@counter' do

    node = Node.create('color', 'red', foo: 'bar')
    expect(node.name).to eq '1'
    expect(node.type).to eq 'color'
    expect(node.value).to eq 'red'
    expect(node.attribute(:foo)).to eq 'bar'
    hash = {type: 'color', value: 'red', foo: 'bar'}
    expect(node.content).to eq hash

  end


end
