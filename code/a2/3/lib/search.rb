class Search
  
  attr_accessor :board, :goal_tiles
  
  def initialize(tiles,goal_tiles)
    @board = Board.new(tiles,goal_tiles)
    @goal_tiles = @board.goal_tiles
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