$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'
require 'active_support'
require 'tree'

require 'lib/math_ext'


module Decision
  def self.subset(set, attribute, attribute_value)
    set.select {|example| example[attribute] == attribute_value}
  end


  def self.probability(set, attribute, attribute_value)
    subset(set, attribute, attribute_value).size.to_f / set.size.to_f
  end

  def self.entropy(set, decision_attribute)
    decision_attribute.values.sum do |v|
      probability = probability(set, decision_attribute, v)
      probability.zero? ? 0.0 : -(probability * Math.log2(probability))
    end
  end

  def self.info(attribute, set, decision_attribute)
    attribute.values.sum do |v|
      probability(set, attribute, v) * entropy(subset(set, attribute, v), decision_attribute)
    end
  end

  def self.gain(set, attribute, decision_attribute)
    entropy(set, decision_attribute) - info(attribute, set, decision_attribute)
  end
end


require 'decision/attribute'
require 'decision/data_set'