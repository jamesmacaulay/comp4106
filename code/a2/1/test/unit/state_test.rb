require File.join(File.dirname(__FILE__),'..','test_helper')

class StateTest < Test::Unit::TestCase
  context "State" do
    setup do
      @state = State.new
    end
    
    context "#possible_moves" do
      setup do
        @moves = @state.possible_moves
      end

      should "be correct" do
        puts @moves.map(&:to_s)
      end
    end
    
    
    
  end
end