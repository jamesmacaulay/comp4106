#!/usr/bin/env ruby
require 'rubygems'
require 'active_support'

class Attribute < Struct.new(:name, :values)
end

module Math
  def self.log2(n); log(n) / log(2); end
end

windy = Attribute.new(:windy, [:strong, :weak])
outlook = Attribute.new(:outlook, [:sunny, :overcast, :rainy])
decision = Attribute.new(:decision, [:yes, :no])

EXAMPLES = [
  {windy => :strong,      outlook => :sunny,      decision => :yes},
  {windy => :strong,      outlook => :sunny,      decision => :yes},
  {windy => :strong,      outlook => :rainy,      decision => :yes},
  {windy => :strong,      outlook => :sunny,      decision => :no},
  {windy => :strong,      outlook => :sunny,      decision => :no},
  {windy => :strong,      outlook => :sunny,      decision => :no},
  {windy => :weak,        outlook => :overcast,   decision => :yes},
  {windy => :weak,        outlook => :overcast,   decision => :yes},
  {windy => :weak,        outlook => :overcast,   decision => :yes},
  {windy => :weak,        outlook => :overcast,   decision => :yes},
  {windy => :weak,        outlook => :rainy,      decision => :yes},
  {windy => :weak,        outlook => :rainy,      decision => :yes},
  {windy => :weak,        outlook => :rainy,      decision => :no},
  {windy => :weak,        outlook => :rainy,      decision => :no}
]

def subset(set, attribute, attribute_value)
  set.select {|example| example[attribute] == attribute_value}
end


def probability(set, attribute, attribute_value)
  subset(set, attribute, attribute_value).size.to_f / set.size.to_f
end

def entropy(set, decision_attribute)
  decision_attribute.values.sum do |v|
    probability = probability(set, decision_attribute, v)
    probability.zero? ? 0.0 : -(probability * Math.log2(probability))
  end
end

def info(attribute, set, decision_attribute)
  attribute.values.sum do |v|
    probability(set, attribute, v) * entropy(subset(set, attribute, v), decision_attribute)
  end
end

def gain(set, attribute, decision_attribute)
  entropy(set, decision_attribute) - info(attribute, set, decision_attribute)
end


