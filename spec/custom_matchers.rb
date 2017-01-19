class IncludeAtLeastOne
  def initialize(&block)
    @block = block
  end

  def matches?(actual)
    @actual = actual
    @actual.any? {|item| @block.call(item) }
  end

  def failure_message_for_should
    "expected #{@actual.inspect} to include at least one matching item, but it did not"
  end

  def failure_message_for_should_not
    "expected #{@actual.inspect} not to include at least one, but it did"
  end
end

def include_at_least_one(&block)
  IncludeAtLeastOne.new &block
end