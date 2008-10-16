require File.join(File.dirname(__FILE__),'..','test_helper')

class BaseTest < Test::Unit::TestCase
  context "DecisionTree::Base" do
    setup do
      @set = DataSet.new(file_for_data 'weather_nominal_data.txt')
      @tree = Base.new(@set)
    end

    context "#initialize" do
      setup do
        
      end
      
      should "make the right tree" do
        @tree.root.printTree
      end
    end
    
  end
  
end