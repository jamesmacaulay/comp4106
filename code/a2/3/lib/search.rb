class Search
  
  attr_reader :root, :board
  
  def initialize(tiles,goal_tiles)
    @board = Board.new(tiles)
    @board.goal_tiles = goal_tiles if goal_tiles
    @root = @board.to_a
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