require File.join(File.dirname(__FILE__),'..','test_helper')

class BoardTest < Test::Unit::TestCase
  context "Board" do
    setup do
      @board = Board.new(Board.valid_sorted_tiles)
    end
    
  
    context "#initialize" do
      context "when given nothing" do
        setup do
          @board = Board.new
        end
        should "produce a board with a valid arrangement of tiles" do
          assert_equal(Board.valid_sorted_tiles, @board.to_a.sort)
        end
      end
    
      context "when given an invalid array" do
        should "raise hell" do
          assert_raises ArgumentError do
            Board.new((0..7).to_a)
          end
          assert_raises ArgumentError do
            Board.new((1..8).to_a)
          end
          assert_raises ArgumentError do
            Board.new((1..8).to_a + [1])
          end
        end
      end
    
      context "when given an array with values 0..8 in some order" do
        setup do
          @board = Board.new([2,1],[0,3,5],[4,7,6],8)
        end

        should "produce a board with the tiles in that order" do
          assert_equal [2,1,0,3,5,4,7,6,8], @board.to_a
        end
      end
    end
  
    context "#blank_can_move?" do
      should "return correct boolean values for :up, :down, :left, and :right" do
        results = {}
        [:up, :down, :left, :right].each do |dir|
          results[dir] = []
          tiles = Board.valid_sorted_tiles
          9.times do
            results[dir] << Board.new(tiles).blank_can_move?(dir)
            tiles.unshift(tiles.pop)
          end
        end
        assert_equal results[:up], (([false] * 3) + ([true] * 6))
        assert_equal results[:down], (([true] * 6) + ([false] * 3))
        assert_equal results[:left], [false,true,true] * 3
        assert_equal results[:right], [true,true,false] * 3
      end
    end
  
    context "#blank_index" do
      setup do
        @board = Board.new([1,5,4,3,0,7,6,8,2])
      end

      should "return the index of the blank tile" do
        assert_equal 4, @board.blank_index
      end
    end
  
    context "#move_blank" do
      should "raise hell if blank cannot be moved in that direction" do
        assert_raises ArgumentError do
          @board.move_blank(:up)
        end
      end

      should "result in a new board with a new move and the same starting tiles" do
        @board.move_blank("right")
        assert_equal [1,0,2,3,4,5,6,7,8], @board.to_a
        assert_equal ["right"], @board.moves
        assert_equal Board.valid_sorted_tiles, @board.starting_tiles
        @board.move_blank("down")
        assert_equal [1,4,2,3,0,5,6,7,8], @board.to_a
        assert_equal ["right", "down"], @board.moves
        assert_equal Board.valid_sorted_tiles, @board.starting_tiles
      end
    end
  
    context "#possible_moves" do
      should "return the possible moves for the blank tile as an array of symbols" do
        possible = @board.possible_moves
        assert_equal 2, possible.size
        assert possible.include?("right")
        assert possible.include?("down")
      end
    end
    
    context "#inspect" do
      should "make a nice looking board" do
        assert_equal "_ 1 2\n3 4 5\n6 7 8\n", @board.inspect
      end
    end
    
    context ".distance" do
      should "return the distance, in moves, from one tile index to another" do
        assert_equal 0, Board.distance(2,2)
        assert_equal 1, Board.distance(1,4)
        assert_equal 2, Board.distance(4,2)
        assert_equal 2, Board.distance(0,6)
        assert_equal 2, Board.distance(8,2)
        assert_equal 4, Board.distance(8,0)
      end
    end
    
    context "#distance_to_goal" do
      should "take a number and return the distance from its current position to its goal position" do
        assert_equal 1, @board.distance_to_goal(2)
        assert_equal 2, @board.distance_to_goal(0)
        assert_equal 3, @board.distance_to_goal(8)
      end
    end
    
    context "#estimated_moves_to_goal" do
      should "return the sum of all goal distances divided by 2, rounding up" do
        assert_equal 7, @board.estimated_moves_to_goal
      end
    end
    
    context "#undo" do
      should "undo last move" do
        @board.move_blank(:down)
        @board.undo
        assert_equal [], @board.moves
        assert_equal Board.valid_sorted_tiles, @board.to_a
      end
    end
    
  
  end
end