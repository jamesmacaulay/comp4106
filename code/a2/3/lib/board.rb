require 'digest/md5'

class Board
  DIRECTIONS = {
    "up" => [(3..8).to_a, -3, "down"],
    "down" => [(0..5).to_a, +3, "up"],
    "left" => [[1,2,4,5,7,8], -1, "right"],
    "right" => [[0,1,3,4,6,7], +1, "left"]
  }
  
  attr_accessor :goal_tiles
  DEFAULT_GOAL_TILES = [1,2,3,8,0,4,7,6,5]
  
  def initialize(*ary)
    ary = ary.flatten
    if ary.empty?
      @tiles = Board.valid_sorted_tiles.randomize
    elsif ary.uniq.sort != Board.valid_sorted_tiles
      raise ArgumentError.new("Must provide either no arguments, or a valid array with numbers 0 through 8.")
    else
      @tiles = ary.dup
    end
    @starting_tiles = @tiles.dup
    @moves = []
    @goal_tiles = DEFAULT_GOAL_TILES
  end
  
  def move_blank(dir, traceless=false)
    dir = dir.to_s
    unless blank_can_move?(dir)
      #p self
      #p dir
      raise ArgumentError.new("Possible moves for blank are #{possible_moves.join(', ')}.")
    end
    #puts "moving #{dir.to_s}"
    @moves << dir unless traceless
    target_index = blank_index + DIRECTIONS[dir][1]
    @tiles[blank_index] = @tiles[target_index]
    @tiles[target_index] = 0
    self
  end
  
  def neighbour(direction)
    other = self.dup
    other.move_blank(direction)
  end
  
  def blank_index
    @tiles.index(0)
  end
  
  def blank_can_move?(dir)
    dir = dir.to_s
    raise ArgumentError.new("Must give 'up', 'down', 'left', or 'right'") unless DIRECTIONS[dir]
    DIRECTIONS[dir].first.include?(blank_index)
  end
  
  def possible_moves
    DIRECTIONS.keys.select {|k| blank_can_move?(k)}.sort
  end
  
  def to_a
    @tiles.dup
  end
  
  def starting_tiles
    @starting_tiles.dup
  end
  
  def moves
    @moves.dup
  end
  
  def solved?
    @tiles == goal_tiles
  end
  
  def estimated_moves_to_goal
    (@tiles.sum {|n| distance_to_goal(n)} / 2.0).ceil
  end
  
  def estimated_moves_to_goal_2
    @tiles.sum {|n| distance_to_goal(n)}
  end
  
  def distance_to_goal(num = nil)
    i1 = @tiles.index(num)
    i2 = goal_tiles.index(num)
    Board.distance(i1,i2)
  end
  
  def undo
    #puts "undo"
    raise StandardError.new("There are no moves to undo") if @moves.empty?
    move_blank(Board.opposite(@moves.pop), true)
    self
  end
  
  def inspect
    @tiles.in_groups_of(3).map {|row| row.map {|cell| cell.zero? ? '_' : cell.to_s}.join(' ')}.join("\n") + "\n"
  end
  
  def dup
    Marshal.load(Marshal.dump(self))
  end
  
  def solvable?
    Board.parity(@tiles) == Board.parity(goal_tiles)
  end
  
  def self.parity(perm)
    sum = pairs.sum do |x,y|
      if x < y and perm.index(x) < perm.index(y)
        1
      else
        0
      end
    end
    sum % 2
  end
  
  def self.pairs
    @pairs ||= begin
      s = Set.new
      (1..8).to_a.each do |i|
        (1..8).to_a.each do |j|
          s << [i,j] unless i == j
        end
      end
      s.to_a
    end
  end
  
  def self.valid_sorted_tiles
    (0..8).to_a
  end
  
  def self.opposite(dir)
    dir = dir.to_s
    raise ArgumentError.new("Must give 'up', 'down', 'left', or 'right'") unless DIRECTIONS[dir]
    DIRECTIONS[dir][2]
  end
  
  def self.distance(i1,i2)
    (i1 % 3 - i2 % 3).abs + (i1 / 3 - i2 / 3).abs
  end
  
end