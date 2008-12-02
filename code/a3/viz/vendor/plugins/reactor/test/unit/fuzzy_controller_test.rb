require File.join(File.dirname(__FILE__),'..','test_helper')

class FuzzyControllerTest < Test::Unit::TestCase
  
  context "FuzzyController" do

    context "#initialize" do
      should "take a plant and make membership functions" do
        fc = FuzzyController.new(Plant.new)
        assert_equal 1.0, fc.temp_mf(:cold, 10)
        assert_equal 1.0, fc.temp_mf(:cold, 9)
        assert_equal 0.0, fc.temp_mf(:cold, 40)
        assert_equal 0.0, fc.temp_mf(:cold, 41)
        assert_equal 0.5, fc.temp_mf(:cold, 25)
        assert_equal 1.0, fc.temp_mf(:hot, 70)
        assert_equal 1.0, fc.temp_mf(:hot, 71)
        assert_equal 0.0, fc.temp_mf(:hot, 40)
        assert_equal 0.0, fc.temp_mf(:hot, 39)
        assert_equal 1.0, fc.temp_mf(:perfect, 40)
        assert_equal 0.5, fc.temp_mf(:perfect, 25)
        assert_equal 0.5, fc.temp_mf(:perfect, 55)
        assert_equal 0.0, fc.temp_mf(:perfect, 70)
        assert_equal 0.0, fc.temp_mf(:perfect, 10)
      end
    end
    
  end
  
  
end