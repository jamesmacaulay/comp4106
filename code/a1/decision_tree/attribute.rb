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
  end
end