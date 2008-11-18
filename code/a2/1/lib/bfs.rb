class BFS
  
  attr_reader :stack
  def initialize(check_repeated = true, time_limit=30)
    @check_repeated = check_repeated
    @root = State.new(nil,time_limit)
    @checked = Set.new
    @node_list = [@root]
    @stack = []
    @solutions = []
  end
  
  def go
    until @node_list.empty? do
      e = @node_list.shift
      @stack << e
      #puts e
      e = e.target_state if e.is_a?(Move)
      #p [@node_list.size, stack.size]
      
      if !check_repeated? or !@checked.include?(e.near_array)
        e.possible_moves.each do |move|
          #puts move
          @stack << move
          new_state = move.target_state
          next if new_state == e
          unless new_state.goal_state?
            @node_list << move
            @stack.pop
          else
            @solutions << Marshal.load(Marshal.dump(@stack))
          end
        end
      elsif check_repeated?
        #puts "already checked"
      end
      #p @checked if @checked.size < 5
      @checked << e.near_array if check_repeated?
    end
    @solutions.any?
  end
  
  def best_solution
    @best_solution ||= @solutions.max {|x,y| x.last.target_state.time_left <=> y.last.target_state.time_left}
  end
  
  def print_best_solution
    puts (solved? ? best_solution.map(&:to_s) : "No solution found")
  end
  
  def solved?
    @solutions.any?
  end
  
  def check_repeated?
    @check_repeated ? true : false
  end
  
end