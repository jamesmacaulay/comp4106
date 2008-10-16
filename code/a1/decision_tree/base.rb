module DecisionTree
  class Base
    include Tree
    attr_reader :root, :set
    
    def initialize(set)
      @set = set
      evaulate_real_attributes
      generate_nodes
    end
    
    def prettyprint
      @root.printTree
    end
    
    private
    
    def evaulate_real_attributes(vectors = nil, remaining_attributes = nil)
      vectors ||= @set.vectors
      remaining_attributes ||= @set.attributes.map(&:name)
      remaining_attributes.each do |att|
        att = @set.attributes.find {|a| a.name == att}
        if att.kind == :real
          sorted_values = vectors.map {|v| v[@set.attribute_index(att.name)]}.reject {|v| v == '?'}.sort
          middle_values = []
          0.upto(sorted_values.size - 2) do |i|
            middle_values << ((sorted_values[i] + sorted_values[i+1]) / 2.0)
          end
          best_condition_value = nil
          max_gain = nil
          middle_values.each do |val|
            att.comparison_value = val
            gain = @set.gain(att.name, vectors)
            if max_gain.nil? or max_gain < gain
              best_condition_value = val
              max_gain = gain
            end
          end
          att.comparison_value = best_condition_value
        end
      end
    end
    
    def generate_nodes(parent = nil, vectors = nil)
      vectors ||= @set.vectors
      remaining_attributes = parent.nil? ? @set.non_decision_attributes.map(&:name) : (@set.non_decision_attributes.map(&:name) - ancestor_attributes(parent))
      unless parent.nil?
        #puts "parent: #{parent.content} at depth #{depth(parent)}"
        # if all examples associated with parent leaf have same target attribute value
        decision_values = vectors.map {|v| @set.decision_value_of_vector(v)}
        unique_decision_values = decision_values.uniq
        
        if unique_decision_values.size == 1
          #puts "  all examples associated with parent leaf have same target attribute value"
          parent.content = @set.decision_attribute
          return unique_decision_values.first
        end
        
        # if each attribute has been used along this path
        if remaining_attributes.empty?
          #puts "  each attribute has been used along this path"
          return decision_values.first
        end
      end
      evaulate_real_attributes(vectors, remaining_attributes)
      attribute = @set.max_gain_attribute(vectors, remaining_attributes)
      #puts "  max gain attribute: #{attribute}"
      if parent.nil?
        @root = TreeNode.new("ROOT", attribute)
        generate_nodes(@root, vectors)
      else
        @set.values_of_attribute(parent.content).each do |value|
          value_set = @set.subset(parent.content, value, vectors)
          node = TreeNode.new(value, attribute)
          parent << node
          if end_value = generate_nodes(node, value_set)
            node << TreeNode.new(end_value, nil)
          end
        end
      end
      return false
    end
    
    def depth(node)
      if node.isRoot?
        return 0
      else
        return depth(node.parent) + 1
      end
    end
    
    def ancestor_attributes(node)
      if node.isRoot?
        return [node.content]
      else
        return [node.content] + ancestor_attributes(node.parent)
      end
    end
    
  end
end