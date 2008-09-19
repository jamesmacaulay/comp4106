#!/usr/bin/env ruby
require 'rubygems'
require 'active_support'

class Attribute < Struct.new(:name, :values)
end

a = Attribute.new(:a, [:yes, :no])
b = Attribute.new(:b, [:yes, :no]),
decision = Attribute.new(:decision, [:yes, :no])

EXAMPLES = [
  {a => :yes, b => :no, decision => :yes},
  {a => :yes, b => :yes, decision => :yes},
  {a => :no, b => :yes, decision => :no},
  {a => :no, b => :yes, decision => :no}
]


def probability(set, attribute, attribute_value)
  set.select {|example| example[attribute] == attribute_value}.size.to_f / set.size.to_f
end

def entropy(set, attribute)
  sum = attribute.values.sum do |v|
    probability = probability(set, attribute, v)
    #p [v, probability]
    probability * Math.log(probability)
  end
  sum * -1
end
p (Math.log(0.5))
p entropy(EXAMPLES, decision)
