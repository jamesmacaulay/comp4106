module Packing
  class Space
    def initialize(options={})
      raise ArgumentError, "requires a proper array of :measurements" unless options[:measurements] && options[:measurements].is_a?(Array) && options[:measurements].any? && options[:measurements].all? {|m| m.is_a?(Numeric) && m > 0}
      raise ArgumentError, ":offsets must be a proper array of offsets" unless options[:offsets].nil? || (options[:offsets].is_a?(Array) && options[:offsets].size == options[:measurements].size && options[:offsets].all? {|o| o.is_a?(Numeric) && o > 0})
      #raise ArgumentError, ":overlappers must be an array of other spaces" unless options[:overlappers].nil? || options[:overlappers].is_a?(Array) && options[:overlappers].all? {|o| o.is_a?(Space)}
      
      @measurements = @original_measurements = options[:measurements]
      @offsets = options[:offsets] || ([0] * arity)
      @indexes = (0..(arity - 1)).to_a
      #@overlappers = options[:overlappers] || []
    end
    
    def indexes
      @indexes.dup
    end
    
    # def overlappers
    #   @overlappers.dup
    # end
    
    # def replace_overlapper(original, replacements)
    #   replacements = [replacements].flatten
    #   @overlappers.delete(original)
    #   @overlappers += replacements
    #   self
    # end
    
    def &(other_space)
      own_corners_in_other_space
    end
    
    def corners
      @corners ||= {}
      @corners[@measurements] ||= begin
        corners = []
        # go through permutations of near and far offsets
        (2 ** arity).times do |n|
          binary_string = n.to_s(2)
          binary_string = ('0' * (arity - binary_string.size)) + binary_string
          binary_string = binary_string.reverse
          corner = []
          index = 0
          # each 0 or 1 decides whether to use the near or far offset for the
          # corresponding axis of this corner.
          binary_string.each_char do |digit|
            corner << [@offsets,far_offsets][digit.to_i][index]
            index += 1
          end
          corners << corner
        end
        corners
      end
    end
    
    def far_offsets
      @far_offsets ||= {}
      @far_offsets[@measurements] ||= @indexes.map {|i| @offsets[i] + @measurements[i]}
    end
    
    def contains_point(point_offsets)
      
    end
    
    def offsets
      @offsets.dup
    end
    
    def offsets=(new_offsets)
      raise ArgumentError, "requires an array of offsets" unless new_offsets.nil? || (new_offsets.is_a?(Array) && new_offsets.size == options[:measurements].size && new_offsets.all? {|o| o.is_a?(Numeric) && o > 0})
      @offsets = new_offsets
    end
    
    def measurements
      @measurements.dup
    end
    
    def original_measurements
      @original_measurements.dup
    end
    
    def arity
      @arity ||= @measurements.size
    end
    
    def volume
      @volume ||= (@measurements.inject(1) {|product,m| product *= m})
    end
    
    # mapping is an array of indexes
    # [2,0,1] would transform measurements [1,2,3] to [3,1,2]
    def rotate(mapping)
      raise ArgumentError, "requires an array of indexes" unless mapping.sort == @indexes
      @measurements = mapping.map {|m| @measurements[m]}
    end
    
    def reset_rotation
      @measurements = @original_measurements
    end
    
    def rotate_mapping_permutations
      @rotate_mapping_permutations ||= @indexes.permutations
    end
    
    def can_fit_inside?(other_space)
      other_measurements = other_space.measurements
      @measurements.each_with_index do |m,i|
        return false if other_space.measurements[i] < m
      end
      return true
    end
    
    def can_contain?(other_space)
      other_space.can_fit_inside?(self)
    end
    
  end
end