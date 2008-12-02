require File.join(File.dirname(__FILE__),'..','reactor')
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'ruby-debug'
require 'benchmark'

def time(times = 1)
  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end