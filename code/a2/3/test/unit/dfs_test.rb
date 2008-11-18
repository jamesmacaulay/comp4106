require File.join(File.dirname(__FILE__),'..','test_helper')

class DFSTest < Test::Unit::TestCase
  context "DFS" do
    setup do
      #@dfs = DFS.new(5,4,0,6,1,8,7,3,2)
      #@dfs = DFS.new(1,2,0,8,4,3,7,6,5)
    end
    
    context "#go" do
      should "go" do
        p @dfs.board
        @dfs.go
        p @dfs.moves
        assert @dfs.solved?
        d = @dfs.board.dup
        d.move_blank(:left)
        
        assert_not_equal @dfs.board.moves, d.moves
        assert_not_equal @dfs.board.to_a, d.to_a
      end
    end
  
  end
end