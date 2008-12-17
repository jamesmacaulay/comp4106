$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'
require 'active_support'

module Packing
  class InvalidActionError < StandardError
  end
  class InvalidPlacementError < InvalidActionError
  end
end

require 'packing/validations'
require 'packing/dimensional'
require 'packing/space'
require 'packing/container'
require 'packing/item'
require 'packing/job'
require 'packing/worker'