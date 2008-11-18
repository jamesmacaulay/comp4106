class AStar < Search
  attr_accessor :heuristic_method
  def initialize(tiles,goal_tile_ary,heuristic_method = nil)
    super(tiles,goal_tile_ary)
    @root = @board.to_a
    @g = {@root => 0}
    @h = {}
    @parents = {@root => nil}
    @successors = {}
    @heuristic_method = heuristic_method || :estimated_moves_to_goal
    @open = Heap.new(@root) { |a,b| f(a) <=> f(b) }
    @closed = Set.new
    @solved = false
  end
  
  def go
    return false unless board.solvable?
    until solved? or @open.empty?
      best_open = @open.extract
      successors = successors_of(best_open)
      @successors[best_open] = successors
      @closed << best_open
      
      successors.each do |node|
        if not @g[node]
          update(node,best_open)
          @open.insert(node)
        elsif @g[node] > (@g[best_open] + 1)
          if previous_parent = @parents[node]
            @successors[previous_parent] = @successors[previous_parent] - [node]
          end
          update(node,best_open)
          update_successors(node)
        end
        if node == goal_tiles
          self.board = real_board_for(node)
          break
        end
      end
    end
    solved?
  end
  
  def examined_state_count
    @g.keys.size
  end
  
  def real_board_for(tiles)
    if tiles == @root
      return board
    else
      parent = @parents[tiles]
      direction = Board.direction(Board.new(parent,goal_tiles).blank_index, Board.new(tiles,goal_tiles).blank_index)
      return real_board_for(parent).neighbour(direction)
    end
  end
  
  def update(node,parent)
    @g[node] = @g[parent] + 1
    @parents[node] = parent
  end
  
  def update_successors(parent)
    if @successors[parent].blank?
      @open.re_sort
      return
    else
      @successors[parent].each do |node|
        update(node,parent)
        update_successors(node)
      end
    end
  end
  
  def successors_of(ary)
    new_board = Board.new(ary,goal_tiles)
    new_board.possible_moves.map do |dir|
      new_board.neighbour(dir).to_a
    end
  end
  
  def goal_tiles
    board.goal_tiles
  end
  
  def h(ary)
    @h[ary] ||= Board.send(@heuristic_method,ary,goal_tiles)
  end
  
  def f(ary)
    @g[ary] + h(ary)
  end
  
end