require File.join(File.dirname(__FILE__),'..','test_helper')

class WorkerTest < Test::Unit::TestCase
  include Packing
  
  context "Worker" do
    setup do
      # cost in cents, weight in grams, measurements in mm
      @containers = [
        Container.new(:measurements => [50,50,50], :cost => 100, :weight => 50)
      ]
      @items = [
        Item.new(:measurements => [50,50,50], :weight => 20)
      ].flatten
      @job = Job.new(:containers => @containers, :items => @items)
    end

    should "#initialize" do
      worker = Worker.new(@job)
      p worker.dna
      job = worker.perform_job
    end
  end
  
  
end