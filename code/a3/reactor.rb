$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'
require 'active_support'
#require 'set'

require 'lib/plant'
require 'lib/fuzzy_controller'

def log(x, n=0)
  p x if n > 1
end