require File.join(File.dirname(__FILE__),'..','test_helper')

class SpaceTest < Test::Unit::TestCase
  include Packing
  context "Space" do
    setup do
      @space = Space.new(:measurements => [5,10,15], :offsets => [1,1,1])
    end

    context "#measurements" do
      should "return the correct measurements" do
        assert_equal [5,10,15], @space.measurements
      end
    end

    context "#offsets" do
      should "return the correct offsets" do
        assert_equal [1,1,1], @space.offsets
      end
    end

    context "#corners" do
      should "return the correct corners" do
        assert_equal [[1,1,1],[6,1,1],[1,11,1],[6,11,1],[1,1,16],[6,1,16],[1,11,16],[6,11,16],], @space.corners
      end
    end
    
    
    
  end
  
  
end