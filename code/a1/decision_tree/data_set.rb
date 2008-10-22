module DecisionTree
  class DataSet
    
    attr_reader :relation, :attributes, :vectors
    attr_accessor :decision_attribute
    
    def initialize(filename_or_other_set, options = {})
      @relation = ''
      @attributes = []
      @vectors = []
      if filename_or_other_set.is_a?(DataSet)
        range = options[:range] || (0..-1)
        @relation = filename_or_other_set.relation
        @attributes = filename_or_other_set.attributes
        @vectors = filename_or_other_set.vectors[range]
      else
        File.open(filename_or_other_set, 'r') do |io|
          line_num = 0
          io.each do |line|
            puts "line #{line_num += 1}" if line_num % 500 == 0
            parse_line(line)
          end
        end
      end
      @decision_attribute = @attributes.map(&:name).last
    end
    
    def half_sets
      mid = ((vectors.size - 1) / 2)
      [self.class.new(self, 0..mid), self.class.new(self, ((mid + 1)..-1))]
    end

    def subset(attribute, value, set = @vectors)
      index = attribute_index(attribute)
      if value.is_a?(Array)
        if value.first == '<'
          set.select {|v| v[index] < value.last}
        else
          set.select {|v| v[index] >= value.last}
        end
      else
        set.select {|v| v[index] == value}
      end
    end

    def probability(attribute, value, set = @vectors)
      a,b = subset(attribute, value, set).size.to_f, set.size.to_f
      #puts "        probability of attribute #{attribute} with value #{value} in that set is (#{a}/#{b}) = #{a/b}"
      a/b
    end

    def entropy(set = @vectors)
      return 1.0 if set.empty?
      #puts "      calculating entropy of set with #{set.size} examples..."
      values = decision_attribute_object.values.map do |v|
        probability = probability(@decision_attribute, v, set)
        probability.zero? ? 0.0 : -(probability * Math.log2(probability))
      end
      e = values.sum
      #puts "      entropy of set with #{set.size} examples is (#{values.map {|v| "(#{v})"}.join(" + ")}) = #{e}"
      e
    end

    def info(attribute, set = @vectors)
      #puts "      calculating info"
      attribute_object(attribute).values.sum do |v|
        probability(attribute, v, set) * entropy(subset(attribute, v, set))
      end
    end
  
    def gain(attribute, set = @vectors)
      #puts "    calculating gain of attribute #{attribute}..."
      g = entropy(set) - info(attribute, set)
      #puts "    gain of attribute #{attribute} is #{g}"
      g
    end
    
    def max_gain_attribute(set = @vectors, remaining_attributes = nil)
      return nil if set.empty?
      
      if remaining_attributes
        remaining_attributes = non_decision_attributes.select {|a| remaining_attributes.include?(a.name)}
      else
        remaining_attributes = non_decision_attributes
      end
      sorted = remaining_attributes.sort_by do |a|
        gain(a.name, set)
      end
      sorted.last.name
    end
    
    def non_decision_attributes
      @attributes.reject {|a| a.name == @decision_attribute}
    end
    
    def values_of_attribute(name)
      @attributes.find {|a| a.name == name}.values
    end
    
    def decision_value_of_vector(v)
      v[attribute_index(@decision_attribute)]
    end
    
    def attribute_index(name)
      attributes.map(&:name).index(name)
    end
    
    def best_value(attribute_name, vectors = @vectors)
      attribute = attribute_object(attribute_name)
      #p attribute
      attribute.values.max do |a,b|
        probability(attribute.name, a, vectors) <=> probability(attribute.name, b, vectors)
      end
    end
    
    def vector_value(vector,attribute_name)
      vector[attribute_index(attribute_name)]
    end
    
    private
    
    def attribute_object(name)
      @attributes.find {|a| a.name == name}
    end
    
    def decision_attribute_object
      attribute_object(@decision_attribute)
    end
    
    def parse_line(line)
      stripped = line.strip.gsub(/\'/,'')
      case stripped.first
      when '%','':  return nil
      when '@':     parse_declaration(stripped)
      else          parse_vector(stripped)
      end
    end
    
    def parse_declaration(line)
      case line
      when /^\s*@relation\s+(\w+)$/
        @relation = $1
      when /^\s*@attribute\s+(\S+)\s+\{(.*)\}$/
        name,values = $1, $2
        values = values.split(/\s*\,\s*/)
        @attributes << Attribute.new(name, values.map {|v| converted_value(v)})
      when /^\s*@attribute\s+(\w+)\s+(\w+)$/
        name, type = $1, $2
        @attributes << Attribute.new(name, type.downcase.to_sym)
      end
    end
    
    def parse_vector(line)
      @vectors << line.split(/\,/).map {|val| converted_value(val)}
    end
    
    def converted_value(val)
      case val
      when /^\d+\.\d+$/
        val.to_f
      when /^\d+$/
        val.to_i
      else
        val.strip
      end
    end
    
  end
end