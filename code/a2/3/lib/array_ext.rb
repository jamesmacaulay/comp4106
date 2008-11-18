class Array
  def randomize
    list, result = self.dup, []
    until list.empty?
      result << list.rand
      list.delete result.last
    end
    result
  end
end