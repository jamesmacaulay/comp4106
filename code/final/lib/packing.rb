$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'
require 'active_support'

module Packing
  class InvalidPlacementError < StandardError
  end
end

require 'packing/validations'
require 'packing/space'
require 'packing/container'
require 'packing/item'