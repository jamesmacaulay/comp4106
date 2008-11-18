class AStar < Search
  
  def initialize(tiles,goal_tiles = nil,heuristic_method = nil)
    super(tiles,goal_tiles)
    @heuristic_method = heuristic_method || :estimated_moves_to_goal
    @open = Heap.new(root) do |a,b|
      Board.send(@heuristic_method,a) <=> Board.send(@heuristic_method,b)
    end
    @closed = Set.new
  end
  
  def go
    until solved? or @open.empty?
      best_open = @open.extract
      successors = best_open.successors
      @closed.insert(best_open)
      
      successors.each do |node|
        unless @open.include?(node) or @closed.include?(node)
          node.g = node.moves.size
          
          @open.insert(node)
        else
          
        end
      end
    end
  end
  
end