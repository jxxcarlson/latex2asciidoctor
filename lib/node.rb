require 'tree'
require_relative 'counter'

class Node < Tree::TreeNode

  attr_reader :content

  @@counter = Counter.new

  def self.create(type, value, option={})
    hash = {type: type, value: value}
    Node.new(@@counter.get, hash.merge(option))
  end

  def attribute(attribute)
    content[attribute]
  end

  def type
    attribute(:type)
  end

  def value
    attribute(:value)
  end


end
