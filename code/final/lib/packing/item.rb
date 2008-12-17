module Packing
  class Item < Space
    @@rotation_mapping_permutations = []
    def empty?
      false
    end
    
    def initialize(options={})
      super
      @original_measurements = @measurements.dup
      
      raise ArgumentError, "requires a weight" unless options[:weight] && options[:weight].is_a?(Numeric) && options[:weight] > 0
      @weight = options[:weight]
    end
    
    def original_measurements
      @original_measurements.dup
    end
    
    def weight
      @weight.dup
    end
    
    # mapping is an array of indexes
    # [2,0,1] would transform measurements [1,2,3] to [3,1,2]
    def rotate(mapping)
      raise ArgumentError, "requires an array of indexes" unless mapping.sort == @indexes
      @measurements = mapping.map {|m| @measurements[m]}
    end
    
    def rotate_to_position(new_measurements)
      validate_measurements(new_measurements, :name => "measurements")
      raise ArgumentError, "measurements must be a valid rotating of existing measurements" unless new_measurements.sort == @measurements.sort
      @measurements = new_measurements
    end
    
    def rotation_mapping_permutations
      @@rotation_mapping_permutations[arity] ||= @indexes.permutations
    end
    
    def reset_rotation
      @measurements = @original_measurements
    end
    
    def ==(other)
      super && @original_measurements == other.original_measurements
    end
  end
end