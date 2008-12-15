module Packing
  # Spaces are always n-dimensional with edges that run parallel to the axes,
  # so no putting items on a diagonal of any kind.
  class Space
    # :measurements -- an array of one measurement for each axis, e.g. [x,y,z]
    # :offsets -- an array of each axis' offset from the origin, defaults to zeroes
    def initialize(options={})
      raise ArgumentError, "requires a proper array of :measurements" unless options[:measurements] && options[:measurements].is_a?(Array) && options[:measurements].any? && options[:measurements].all? {|m| m.is_a?(Numeric) && m > 0}
      @measurements = (@original_measurements = options[:measurements]).dup
      
      raise ArgumentError, ":offsets must be a proper array of offsets" unless options[:offsets].nil? || (options[:offsets].is_a?(Array) && options[:offsets].size == arity && options[:offsets].all? {|o| o.is_a?(Numeric) && o >= 0})
      @offsets = options[:offsets] || ([0] * arity)
      
      @indexes = (0..(arity - 1)).to_a
      
      #raise ArgumentError, ":overlappers must be an array of other spaces" unless options[:overlappers].nil? || options[:overlappers].is_a?(Array) && options[:overlappers].all? {|o| o.is_a?(Space)}
      #@overlappers = options[:overlappers] || []
    end
    
    def indexes
      @indexes.dup
    end
    
    def measurements
      @measurements.dup
    end
    
    def original_measurements
      @original_measurements.dup
    end
    
    def offsets
      @offsets.dup
    end
    
    def offsets=(new_offsets)
      raise ArgumentError, "requires an array of offsets" unless new_offsets.nil? || (new_offsets.is_a?(Array) && new_offsets.size == options[:measurements].size && new_offsets.all? {|o| o.is_a?(Numeric) && o > 0})
      @offsets = new_offsets
    end
    
    def far_offsets
      @far_offsets ||= {}
      @far_offsets[@measurements] ||= @indexes.map {|i| @offsets[i] + @measurements[i]}
    end
    
    def arity
      @arity ||= @measurements.size
    end
    
    def volume
      @volume ||= (@measurements.inject(1) {|product,m| product *= m})
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
    
    def &(other_space)
      options = {:offsets => [], :measurements => []}
      indexes.each do |i|
        line1 = [@offsets[i], far_offsets[i]]
        line2 = [other_space.offsets[i], other_space.far_offsets[i]]
        return nil unless intersection = self.class.linear_intersection(line1,line2)
        options[:offsets] << intersection.first
        options[:measurements] << intersection.last - intersection.first
      end
      Space.new(options)
    end
    
    def contains_point?(point_offsets)
      raise ArgumentError, "point must be a proper array of offsets" unless point_offsets && point_offsets.is_a?(Array) && point_offsets.size == arity && point_offsets.all? {|o| o.is_a?(Numeric) && o >= 0}
      @indexes.each {|i| return false if point_offsets[i] < offsets[i] || point_offsets[i] > far_offsets[i]}
      return true
    end
    
    # mapping is an array of indexes
    # [2,0,1] would transform measurements [1,2,3] to [3,1,2]
    def rotate(mapping)
      raise ArgumentError, "requires an array of indexes" unless mapping.sort == @indexes
      @measurements = mapping.map {|m| @measurements[m]}
    end
    
    def rotate_mapping_permutations
      @rotate_mapping_permutations ||= @indexes.permutations
    end
    
    def reset_rotation
      @measurements = @original_measurements
    end
    
    def can_fit_inside?(other_space,options = {})
      rotatable = (options.has_key?(:rotatable) ? options[:rotatable] : true)
      other_measurements = (rotatable ? other_space.measurements.sort : other_space.measurements)
      (rotatable ? @measurements.sort : @measurements).each_with_index do |m,i|
        return false if other_measurements[i] < m
      end
      return true
    end
    
    def can_contain?(other_space)
      other_space.can_fit_inside?(self)
    end
    
    def self.linear_collision?(line1,line2)
      lines = setup_linear_comparison(line1,line2)
      return lines.last.first < lines.first.last
    end
    
    def self.linear_intersection(line1,line2)
      lines = setup_linear_comparison(line1,line2)
      return nil unless lines.last.first < lines.first.last
      near_offset = lines.last.first
      far_offset = [lines.first.last, lines.last.last].min
      [near_offset,far_offset]
    end
    
    def ==(other)
      self.offsets == other.offsets && self.measurements == other.measurements && self.original_measurements == other.original_measurements
    end
    
    def eql?(other)
      other.is_a?(self.class) && self == other
    end
    
    protected
    
    def self.setup_linear_comparison(line1,line2)
      [line1,line2].each do |arg|
        unless arg.is_a?(Array) && arg.size == 2 && arg.all?{|n| n >= 0 && n.is_a?(Numeric) } && arg.last >= arg.first
          raise ArgumentError, "both lines must be a two-element array of valid near and far offsets"
        end
      end
      lines = [line1,line2].sort_by(&:first)
    end
    
  end
end