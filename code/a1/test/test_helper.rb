require File.join(File.dirname(__FILE__),'..','decision')
require 'test/unit'
require 'shoulda'


class Test::Unit::TestCase
  include Decision
  
  def file_for_data(name)
    File.join(File.dirname(__FILE__),'..','data',name)
  end
  
end
