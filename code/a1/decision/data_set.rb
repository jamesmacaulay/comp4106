module Decision
  class DataSet
    
    attr_reader :relation, :attributes, :vectors
    attr_accessor :decision_attribute
    
    def initialize(filename)
      @relation = ''
      @attributes = []
      @vectors = []
      File.open(filename, 'r') do |io|
        io.each do |line|
          parse_line(line)
        end
      end
      @decision_attribute = @attributes.map(&:name).last
    end

    def subset(attribute, value, set = @vectors)
      index = attribute_index(attribute)
      set.select {|v| v[index] == value}
    end

    def probability(attribute, value, set = @vectors)
      subset(attribute, value, set).size.to_f / set.size.to_f
    end

    def entropy(set = @vectors)
      decision_attribute_object.values.sum do |v|
        probability = probability(@decision_attribute, v, set)
        probability.zero? ? 0.0 : -(probability * Math.log2(probability))
      end
    end

    def info(attribute, set = @vectors)
      attribute_object(attribute).values.sum do |v|
        probability(attribute, v, set) * entropy(subset(attribute, v, set))
      end
    end
  
    def gain(attribute, set = @vectors)
      entropy(set) - info(attribute, set)
    end
    
    private
    
    def attribute_object(name)
      @attributes.find {|a| a.name == name}
    end
    
    def decision_attribute_object
      attribute_object(@decision_attribute)
    end
    
    def attribute_index(name)
      attributes.map(&:name).index(name)
    end
    
    def parse_line(line)
      stripped = line.strip
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
      when /^\s*@attribute\s+(\w+)\s+\{(.*)\}$/
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
        val
      end
    end
    
  end
end