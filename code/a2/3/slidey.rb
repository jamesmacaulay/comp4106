$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'
require 'active_support'
require 'set'

libs = %w{
  array_ext
  board
  node
  heap
  search
  dfs
  a_star
}
libs.each do |file|
  require "lib/#{file}"
end

def log(x, n=0)
  p x if n > 1
end