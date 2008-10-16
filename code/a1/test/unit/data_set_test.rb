require File.join(File.dirname(__FILE__),'..','test_helper')

class DataSetTest < Test::Unit::TestCase
  
  context "DecisionTree::DataSet" do
    setup do
      @set = DataSet.new(file_for_data 'weather_nominal_data.txt')
    end
    
    context "#initialize" do
      
      should "set relation to relation name in file" do
        assert_equal "weather_nominal", @set.relation
      end
      
      should "set attributes to those in file" do
        assert_equal %w{outlook temperature humidity windy play}, @set.attributes.map(&:name)
      end
      
      should "set attribute values to those in file" do
        assert_equal [%w{sunny overcast rainy}, %w{hot mild cool}, %w{high normal}, %w{TRUE FALSE}, %w{yes no}], @set.attributes.map(&:values)
      end
      
      should "parse the vectors correctly" do
        assert_equal 14, @set.vectors.size
        assert_equal %w{sunny hot high FALSE no}, @set.vectors.first
      end
      
    end
    
    context "#subset" do
      should "return vectors which match the given attribute/value pair" do
        assert_equal 5, @set.subset('outlook', 'sunny').size
      end
    end
    
    context "#probability" do
      should "return the chance that a random vector in the set satisfies the given attribute constraint" do
        assert_equal 5.0/14, @set.probability('outlook', 'sunny')
      end
    end
    
    context "#entropy" do
      should "return the (neg)entropy of the set" do
        assert_equal 0.94, (@set.entropy * 100).round.to_f / 100
      end
    end
    
    context "#info" do
      should "return the expected info for the tree rooted at the given attribute, after that attribute value is known" do
        assert_equal 0.694, (@set.info('outlook') * 1000).round.to_f / 1000
      end
    end
    
    context "#gain" do
      should "return the expected entropy reduction due to knowing value of given attribute" do
        assert_equal 0.048, (@set.gain('windy') * 1000).round.to_f / 1000
        assert_equal 0.247, (@set.gain('outlook') * 1000).round.to_f / 1000
      end
    end
    
    context "#max_gain_attribute" do
      should "return the name of the attribute with the highest gain" do
        assert_equal 'outlook', @set.max_gain_attribute
      end
    end
    
    
  end
  
  
end