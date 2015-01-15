class Counter

  def initialize
    @counter = 0
  end

  def get
    @counter += 1
    "#{@counter}"
  end

end
