class Node
  attr_reader :board
  
  attr_accessor :g, :h
  
  def initialize(board)
    @g,@h = nil
    @board = board
  end
  
  def parent
    if board.moves.empty?
      nil
    else
      Node.new(board.dup.undo)
    end
  end
  
  def successors
    board.possible_moves.map do |direction|
      Node.new(board.dup.move_blank(direction))
    end
  end
  
  def f
    return nil unless g and h
    g + h
  end
  
  # def tiles
  #   @tiles.dup
  # end

  # def possible_moves
  #   board.possible_moves
  # end
  # def neighbours
  #   possible_moves.map {|dir| neighbour(dir)}
  # end
  # 
  # def neighbour(dir)
  #   Node.new(board.move_blank(dir).to_a)
  # end
end