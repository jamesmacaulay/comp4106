class AStar < Search
  
  def initialize(*tiles)
    super(*tiles)
    @open = Set.new
    @open << board.to_a
    @closed = {}
  end
  
  def go
    
  end
  
end