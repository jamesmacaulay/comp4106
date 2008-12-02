require File.join(File.dirname(__FILE__),'..','test_helper')

class ContainerTest < ActiveSupport::TestCase
  
  context "Container" do
    setup do
      
    end

    context "#initialize" do
      should "take a hash of options and produce a corresponding container" do
        c = Container.new(:inches => [16.5, 13.25, 10.75], :cost => 100, :max_pounds => 10)
      end
    end
    
  end
  
  
end