require File.join(File.dirname(__FILE__),'..','test_helper')

class BaseTest < Test::Unit::TestCase
  context "DecisionTree::Base" do
    setup do
    end

    # context "with nominal values" do
    #   setup do
    #     @set = DataSet.new(file_for_data 'weather_nominal_data.txt')
    #     @tree = Base.new(@set)
    #   end
    #   
    #   should "make the right tree" do
    #     puts "NOMINAL WEATHER DATA"
    #     @tree.prettyprint
    #   end
    # end
    
    context "with numeric values" do
       setup do
         @set = DataSet.new(file_for_data 'weather_numeric_data.txt')
         @tree = Base.new(@set)
       end
       
       should "make the right tree" do
         puts "NUMERIC WEATHER DATA"
         @tree.prettyprint
       end
     end
     
     # context "with mushrooms" do
     #    setup do
     #      @full_set = DataSet.new(file_for_data 'mushroom_data.txt')
     #      @training_set, @testing_set = @full_set.half_sets
     #      @tree = Base.new(@training_set)
     #    end
     #    
     #    should "make the right tree" do
     #      puts "MUSHROOM DATA"
     #      @tree.prettyprint
     #      show_ratio_correct
     #    end
     #  end
     #  
     #  context "with votes" do
     #    setup do
     #      @full_set = DataSet.new(file_for_data 'vote_data.txt')
     #      @training_set, @testing_set = @full_set.half_sets
     #      @tree = Base.new(@training_set)
     #    end
     #    
     #    should "make the right tree" do
     #      puts "VOTE DATA"
     #      @tree.prettyprint
     #      show_ratio_correct
     #    end
     #  end
     
     # context "with poker data" do
     #   setup do
     #     @full_set = DataSet.new(file_for_data 'poker_hand_reduced.txt')
     #     @training_set, @testing_set = @full_set.half_sets
     #     @tree = Base.new(@testing_set)
     #   end
     #   
     #   should "make the right tree" do
     #     puts "IRIS DATA"
     #     @tree.prettyprint
     #     show_ratio_correct
     #   end
     # end
    #  
     context "with iris data" do
       setup do
         @full_set = DataSet.new(file_for_data 'iris_data.txt')
         @training_set, @testing_set = @full_set.half_sets
         @tree = Base.new(@testing_set)
       end
       
       should "make the right tree" do
         puts "IRIS DATA"
         @tree.prettyprint
         show_ratio_correct
       end
     end
    
    # context "with labor data" do
    #   setup do
    #     @full_set = DataSet.new(file_for_data 'labor_data.txt')
    #     @training_set, @testing_set = @full_set.half_sets
    #     @tree = Base.new(@testing_set)
    #   end
    #   
    #   should "make the right tree" do
    #     puts "LABOR DATA"
    #     @tree.prettyprint
    #     show_ratio_correct
    #   end
    # end
    
  end
  
  private
  
  def show_ratio_correct
    num_correct = @testing_set.vectors.sum {|v| @tree.correct?(v) ? 1 : 0 }
    testing_set_size = @testing_set.vectors.size
    puts "#{@testing_set.probability(@testing_set.decision_attribute, @testing_set.values_of_attribute(@testing_set.decision_attribute))}"
    puts "testing set size: #{testing_set_size}"
    puts "number correct: #{num_correct}"
    puts "ratio correct: #{num_correct / testing_set_size.to_f}"
  end
  
end