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

    context "#indexes" do
      should "return the correct indexes" do
        assert_equal [0,1,2], @space.indexes
      end
    end

    context "#contains_point?" do
      should "return false if the space does not contain the point" do
        assert_equal false, @space.contains_point?([1,1,0])
        assert_equal false, @space.contains_point?([7,11,16])
      end
      should "return true if the space contains the point" do
        assert_equal true, @space.contains_point?([1,1,1])
        assert_equal true, @space.contains_point?([6,9,16])
      end
    end

    context "#&" do
      should "return the given space when it is completely contained in self" do
        contained = Space.new(:measurements => [1,1,1], :offsets => [2,2,2])
        
        assert_equal contained, @space & contained
        assert_equal contained, contained & @space
      end
      should "return the correct intersection when there is a partial overlap" do
        overlapping = Space.new(:measurements => [2,2,2], :offsets => [0,0,0])
        expected = Space.new(:measurements => [1,1,1], :offsets => [1,1,1])
        
        assert_equal expected, @space & overlapping
        assert_equal expected, overlapping & @space
      end
      should "return nil when there is no intersection" do
        disjointed = Space.new(:measurements => [1,10,10], :offsets => [0,0,0])
        
        assert_equal nil, @space & disjointed
        assert_equal nil, disjointed & @space
      end
    end
    
    context ".linear_intersection" do
      should "return the correct intersection of two lines represented by two-element arrays of near and far offsets" do
        assert_equal [1,2], Space.linear_intersection([0,2],[1,3])
        assert_equal [1,2], Space.linear_intersection([1,3],[0,2])
        assert_equal [1,3], Space.linear_intersection([1,3],[0,4])
      end
    end
    
  end
  
  
end