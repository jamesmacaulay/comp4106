$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'
require 'active_support'
#require 'set'

require 'lib/plant'

def log(x, n=0)
  p x if n > 1
end