require File.join(File.dirname(__FILE__),'..','test_helper')

class AStarTest < Test::Unit::TestCase
  context "AStar" do
    setup do
      #@a = AStar.new(5,4,0,6,1,8,7,3,2)
      @a = AStar.new(1,2,0,8,4,3,7,6,5)
    end
    
    context "#go" do
      should "go" do
        p @a.board
        @a.go
        p @a.moves
        assert @a.solved?
      end
    end
  
  end
end