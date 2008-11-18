class DFS < Search
  
  def initialize(tiles, goal_tiles=nil)
    @closed = Set.new
    # @closed = {}
    super(tiles, goal_tiles)
  end
  
  def first_open_move
    @board.possible_moves.find do |dir|
      result = !@closed.include?(@board.move_blank(dir).to_a)
      @board.undo
      result
    end
  end
  
  def go
    failure = false
    #times = 0
    until solved? or failure
      #p times += 1
      current_moves = moves
      if @closed.include?(@board.to_a)
        if current_moves.empty?
          failure = true
          next
        end
      else
        #@closed[@board.to_a] = true
        @closed << @board.to_a
      end
      if move = first_open_move
        @board.move_blank(move)
      elsif current_moves.empty?
        failure = true
      else
        @board.undo
      end
    end
    solved?
  end
  
end