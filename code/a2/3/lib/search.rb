class Search
  
  attr_reader :root, :board
  
  def initialize(*tiles)
    @root = Node.new(*tiles)
    @board = @root.board
  end
  
  def moves
    @board.moves
  end
  
  def tiles
    @board.to_a
  end
  
  def starting_tiles
    @board.starting_tiles
  end
  
  def solved?
    @board.solved?
  end
  
  
end