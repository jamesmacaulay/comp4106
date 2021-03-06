module Packing
  # Spaces are always n-dimensional with edges that run parallel to the axes,
  # so no putting items on a diagonal of any kind.
  class Space
    include Dimensional
    include Comparable
    include Validations
    
    attr_accessor :container
    
    # :measurements -- an array of one measurement for each axis, e.g. [x,y,z]
    # :offsets -- an array of each axis' offset from the origin, defaults to zeroes
    # :overlappers -- an array of other spaces which overlap this one; each space is responsible for updating overlappers when split
    def initialize(options={})
      @@axes_array = {}
      
      @measurements = validate_measurements(options[:measurements])
      @offsets = validate_offsets(options[:offsets], :allow_nil => true) || ([0] * arity)
      @overlappers = validate_spaces(options[:overlappers], :allow_nil => true, :name => ":overlappers") || []
      @container = validate_spaces(options[:container], :class => Container, :allow_nil => true)
      raise 'hell' if @container.nil? and !self.is_a?(Item)
      
      @axes ||= @@axes_array[arity] ||= (0..(arity - 1)).to_a
    end
    
    def overlappers
      @overlappers.dup
    end
    
    def axes
      @axes.dup
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
      @far_offsets[@measurements] ||= @axes.map {|i| @offsets[i] + @measurements[i]}
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
    
    # returns the intersection of this space and another
    def &(other_space)
      options = {:offsets => [], :measurements => []}
      @axes.each do |i|
        line1 = [@offsets[i], far_offsets[i]]
        line2 = [other_space.offsets[i], other_space.far_offsets[i]]
        return nil unless intersection = self.class.linear_intersection(line1,line2)
        options[:offsets] << intersection.first
        options[:measurements] << (intersection.last - intersection.first)
      end
      Space.new(options.merge(:container => @container))
    end
    
    # returns an array of maximum-size overlapping spaces which combine to exactly
    # compliment an intersection in forming the whole of this space.
    def split_on(other_space)
      spaces = []
      @axes.each do |i|
        self_line = [@offsets[i], far_offsets[i]]
        other_line = [other_space.offsets[i], other_space.far_offsets[i]]
        return [Space.new(:measurements => measurements, :offsets => offsets, :container => @container)] unless [self_line] != (split = self.class.linear_split(self_line,other_line))
        split.each do |line|
          these_offsets = offsets
          these_offsets[i] = line.first
          these_far_offsets = far_offsets
          these_far_offsets[i] = line.last
          these_measurements = @axes.map {|j| these_far_offsets[j] - these_offsets[j]}
          spaces << Space.new(:measurements => these_measurements, :offsets => these_offsets, :container => @container)
        end
      end
      spaces
    end
    
    def contains_point?(point_offsets)
      raise ArgumentError, "point must be a proper array of offsets" unless point_offsets && point_offsets.is_a?(Array) && point_offsets.size == arity && point_offsets.all? {|o| o.is_a?(Numeric) && o >= 0}
      @axes.each {|i| return false if point_offsets[i] < offsets[i] || point_offsets[i] > far_offsets[i]}
      return true
    end
    
    def contains?(space_or_point)
      if space_or_point.is_a?(Space)
        return self & space == space
      else
        return contains_point?(point_offsets)
      end
    end
    
    def can_fit_inside?(other_space, options = {})
      return false unless other_space.empty?
      rotatable = (options.has_key?(:rotatable) ? options[:rotatable] : true)
      other_measurements = (rotatable ? other_space.measurements.sort : other_space.measurements)
      (rotatable ? @measurements.sort : @measurements).each_with_index do |m,i|
        return false if other_measurements[i] < m
      end
      return true
    end
    
    def can_contain?(other_space, options = {})
      other_space.can_fit_inside?(self, options)
    end
    
    def ==(other)
      @offsets == other.offsets && @measurements == other.measurements
    end
    
    def eql?(other)
      other.is_a?(self.class) && self == other
    end
    
    def <=>(other)
      if (axes_comparison = @axes <=> other.axes) != 0
        return axes_comparison
      elsif (volume_comparison = self.volume <=> other.volume) != 0
        return volume_comparison
      elsif (sum_comparison = @offsets.sum <=> other.offsets.sum) != 0
        return sum_comparison
      else
        @axes.each do |i|
          # "bottom up"
          if (single_axis_comparison = other.offsets[i] <=> @offsets[i]) != 0
            return single_axis_comparison
          end
        end
      end
      return 0
    end
    
    def dup
      self.class.new(:measurements => measurements, :offsets => offsets)
    end
    
    def inspect
      "#<#{self.class.name}.new(:measurements => #{@measurements.inspect}, :offsets => #{@offsets.inspect}, :container => #{@container.nil? ? 'nil' : @container.measurements.inspect})>"
    end
    
    # [0,1],[1,2]
    #=> false
    # [0,2],[1,3]
    #=> true
    def self.linear_collision?(line1,line2)
      lines = setup_linear_comparison(line1,line2)
      return sorted_lines_have_collision?(lines)
    end
    
    # [0,1],[1,2]
    #=> nil
    # [0,2],[1,3]
    #=> [1,2]
    def self.linear_intersection(line1,line2)
      lines = setup_linear_comparison(line1,line2)
      return nil unless sorted_lines_have_collision?(lines)
      near_offset = lines.last.first
      far_offset = [lines.first.last, lines.last.last].min
      [near_offset,far_offset]
    end
    
    def self.linear_split(this_line,that_line)
      intersection = linear_intersection(this_line,that_line)
      return [this_line] unless intersection
      split = [[this_line.first, intersection.first], [intersection.last, this_line.last]]
      split.reject {|line| line.first == line.last}
    end
    
    protected
    
    def self.sorted_lines_have_collision?(lines)
      lines.last.first < lines.first.last
    end
    
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