#!/usr/bin/env ruby
require 'decision_tree'

set = DecisionTree::DataSet.new(ARGV[0])
tree = DecisionTree::Base.new(set)
tree.prettyprint