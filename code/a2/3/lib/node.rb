class Node
  def initialize(*tiles)
    @tiles = tiles.flatten
    board
  end
  
  def tiles
    @tiles.dup
  end
  def board
    Board.new(@tiles)
  end
  def possible_moves
    board.possible_moves
  end
  def neighbours
    possible_moves.map {|dir| neighbour(dir)}
  end
  
  def neighbour(dir)
    Node.new(board.move_blank(dir).to_a)
  end
end