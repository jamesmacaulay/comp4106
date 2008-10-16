module DecisionTree
  class Base
    include Tree
    attr_reader :root, :set
    
    def initialize(set)
      @set = set
      generate_nodes
    end
    
    private
    
    def generate_nodes(parent = nil, vectors = nil)
      vectors ||= @set.vectors
      remaining_attributes = parent.nil? ? @set.non_decision_attributes.map(&:name) : (@set.non_decision_attributes.map(&:name) - ancestor_attributes(parent))
      unless parent.nil?
        # if all examples associated with parent leaf have same target attribute value
        decision_values = vectors.map {|v| @set.decision_value_of_vector(v)}
        unique_decision_values = decision_values.uniq
        
        if unique_decision_values.size == 1
          #puts "all examples associated with parent leaf have same target attribute value"
          parent.content = @set.decision_attribute
          return unique_decision_values.first
        end
        
        # if each attribute has been used along this path
        if remaining_attributes.empty?
          #puts "each attribute has been used along this path"
          return decision_values.first
        end
      end
      
      attribute = @set.max_gain_attribute(vectors, remaining_attributes)
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
    
    def ancestor_attributes(node)
      if node.isRoot?
        return [node.content]
      else
        return [node.content] + ancestor_attributes(node.parent)
      end
    end
    
  end
end