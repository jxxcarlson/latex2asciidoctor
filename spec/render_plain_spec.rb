require 'rspec'
require_relative '../lib/node'
require_relative '../lib/identity_render_node'

describe IdentityRender do

  it 'can render a basic node (e.g., one whose value is a string)' do

    node = Node.create('string', 'red', foo: 'bar')
    puts node.default_render
    expect(node.default_render).to eq 'red'

    node = Node.create(:foo, :bar)
    puts node.default_render
    expect(node.default_render).to eq 'oops '

  end

end
