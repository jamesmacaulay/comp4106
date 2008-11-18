require File.join(File.dirname(__FILE__),'..','test_helper')

class BFSTest < Test::Unit::TestCase
  context "Benchmarks" do
    
    context "with checking repeated states" do
      # user     system      total        real
      #   0.120000   0.000000   0.120000 (  0.125848)
      # No solution found
      should "take some amount of time" do
        @bfs = BFS.new(true)
        time {@bfs.go}
        @bfs.print_best_solution
      end
    end
    
    context "without checking repeated states" do
      should "take some amount of time" do
        @bfs = BFS.new(false)
        time {@bfs.go}
        @bfs.print_best_solution
      end
    end
  
  end
end