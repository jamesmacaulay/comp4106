require File.join(File.dirname(__FILE__),'..','test_helper')

class PlantTest < Test::Unit::TestCase
  
  context "Plant" do

    context "#initialize" do
      should "take a hash of options and produce a corresponding core" do
        plant = Plant.new
        assert_equal 10, plant.max_core_heating
        assert_equal 1000, plant.max_volume
        assert_equal 10..70, plant.temp_range
        assert_equal 30, plant.temp
        assert_equal 750, plant.volume
        
        p plant.history.last
        
        100.times do
          plant.cold_water_restriction = 0.5
          plant.hot_water_restriction = 0.5
          plant.drain_restriction = 0.5
          plant.increment_time
        end
      end
    end
    
  end
  
  
end