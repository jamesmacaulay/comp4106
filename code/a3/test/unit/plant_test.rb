require File.join(File.dirname(__FILE__),'..','test_helper')

class PlantTest < Test::Unit::TestCase
  
  context "Plant" do

    context "#initialize" do
      should "take a hash of options and produce a corresponding core" do
        plant = Plant.new(:max_core_heating => 1, :max_volume => 2, :temp => 3, :volume => 4)
        assert_equal 1, plant.max_core_heating
        assert_equal 2, plant.max_volume
        assert_equal 10, plant.min_temp
        assert_equal 70, plant.max_temp
        assert_equal 3, plant.temp
        assert_equal 4, plant.volume
      end
    end
    
  end
  
  
end