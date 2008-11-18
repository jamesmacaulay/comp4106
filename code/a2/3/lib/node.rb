class Node
  attr_reader :tiles
  
  attr_accessor :parent, :g, :h
  
  def initialize(parent,direction)
    @parent,@direction = parent,direction
    @tiles = board.to_a
    @g,@h = nil
  end
  
  def successors
    board.possible_moves.map do |dir|
      Node.new(self,dir)
    end
  end
  
  def f
    return nil unless g and h
    g + h
  end
  
  def tiles
    @board.to_a
  end
  
  def board
    parent.board.neighbour(direction)
  end

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