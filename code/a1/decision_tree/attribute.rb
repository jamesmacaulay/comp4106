module DecisionTree
  class Attribute
    attr_accessor :name, :values, :kind
    
    def initialize(name, values_or_kind)
      @name = name
      if values_or_kind.is_a?(Array)
        @values = values_or_kind
        @kind = :enumerable
      else
        @values = []
        @kind = values_or_kind
      end
    end
    
    def comparison_value=(val)
      @values = [['<',val],['>=',val]]
    end
    
    def self.value_match(v1,v2)
      if v1.is_a?(Array)
        v1,v2 = v2,v1
      end
      if v2.is_a?(Array)
        if v2.first == '<'
          return v1 < v2.last
        else
          return v1 >= v2.last
        end
      else
        return v1 == v2
      end
    end
  end
end