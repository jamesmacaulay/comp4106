require File.join(File.dirname(__FILE__),'..','test_helper')

class BaseTest < Test::Unit::TestCase
  context "DecisionTree::Base" do
    setup do
    end

    context "with nominal values" do
      setup do
        @set = DataSet.new(file_for_data 'weather_nominal_data.txt')
        @tree = Base.new(@set)
      end
      
      should "make the right tree" do
        @tree.prettyprint
      end
    end
    # 
    # context "with numeric values" do
    #   setup do
    #     @set = DataSet.new(file_for_data 'weather_numeric_data.txt')
    #     @tree = Base.new(@set)
    #   end
    #   
    #   should "make the right tree" do
    #     @tree.prettyprint
    #   end
    # end
    
    # context "with mushrooms" do
    #   setup do
    #     @set = DataSet.new(file_for_data 'mushroom_data.txt')
    #     @tree = Base.new(@set, :split => 0.5)
    #   end
    #   
    #   should "make the right tree" do
    #     @tree.prettyprint
    #   end
    # end
    # 
    # context "with votes" do
    #   setup do
    #     @full_set = DataSet.new(file_for_data 'vote_data.txt')
    #     @training_set, @testing_set = @full_set.half_sets
    #     @tree = Base.new(@training_set)
    #   end
    #   
    #   should "make the right tree" do
    #     @tree.prettyprint
    #   end
    # end
    
  end
  
end