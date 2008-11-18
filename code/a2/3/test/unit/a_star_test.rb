require File.join(File.dirname(__FILE__),'..','test_helper')

class AStarTest < Test::Unit::TestCase
  context "Benchmarks" do
    setup do
      @a = AStar.new([5,4,0,6,1,8,7,2,3],[1,2,3,8,0,4,7,6,5])
      #@a = AStar.new([1,2,0,8,4,3,7,6,5],[1,2,3,8,0,4,7,6,5])
      #@a = AStar.new([1,2,3,0,8,4,7,6,5],[1,2,3,8,0,4,7,6,5])
    end
    
    context "#go" do
      

# estimated_moves_to_goal
#       user     system      total        real
#   4.020000   0.020000   4.040000 (  4.071164)
# 6338 examined states
      should "take some time with :estimated_moves_to_goal" do
        puts "estimated_moves_to_goal"
        @a.heuristic_method = :estimated_moves_to_goal
        time { @a.go }
        puts "#{@a.examined_state_count} examined states"
        assert @a.solved?
      end
      
# misplaced_tile_count
#       user     system      total        real
# 184.430000   1.130000 185.560000 (188.112903)
      # should "take some time with :misplaced_tile_count" do
      #   puts "misplaced_tile_count"
      #   @a.heuristic_method = :misplaced_tile_count
      #   time { @a.go }
      #   assert @a.solved?
      # end
      
# average_heuristic
#       user     system      total        real
#  48.670000   0.270000  48.940000 ( 49.426164)
      # should "take some time with :average_heuristic" do
      #   puts "average_heuristic"
      #   @a.heuristic_method = :average_heuristic
      #   time { @a.go }
      #   assert @a.solved?
      # end
      
    end
  
  end
end