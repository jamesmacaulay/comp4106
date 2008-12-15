require File.join(File.dirname(__FILE__),'..','test_helper')

class PlantTest < Test::Unit::TestCase
  
  context "Plant" do

    context "#initialize" do
      should "take a hash of options and produce a corresponding core" do
        Plant.new
        100.times do
          begin
            plant = Plant.new
            loop do
              plant.increment_time
            end
          rescue StandardError => e
            p e.message
          ensure
            puts plant.history.last.to_yaml
            puts "*** lasted #{plant.history.length} seconds"
          end
        end
      end
    end
    
  end
  
  
end