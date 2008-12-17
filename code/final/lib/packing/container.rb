module Packing
  class Container
    include Dimensional
    include Validations
    
    attr_reader :cost, :weight_without_contents #, :id
    def initialize(options={})
      @measurements = validate_measurements(options[:measurements])
      @weight_without_contents = validate_whole_number(options[:weight], :name => ':weight', :allow_nil => true) || 0
      @cost = validate_whole_number(options[:cost], :name => ':cost', :allow_nil => true) || 0
      
      @space_hash = {[0,0,0] => Space.new(options.slice(:measurements).merge(:container => self))}
    end
    
    def dup
      self.class.new(:measurements => measurements, :cost => cost, :weight => weight)
    end
    
    def empty?
      spaces.all? {|s| s.empty?}
    end
    
    def weight
      self.weight + spaces.sum {|s| s.weight}
    end
    
    def place_item_in_space(item, space, options={})
      place_item_in_space!(item, space, options)
    rescue InvalidPlacementError
      nil
    end
    
    def place_item_in_space!(item, space, options={}, &block)
      raise InvalidPlacementError, "that item could never fit inside that space" unless space.can_contain?(item)
      yield(item,space)
      
      new_spaces = space.split_on(item)
      space.overlappers.each do |s|
        new_spaces << s.split_on(item)
        delete_space(s)
      end
      delete_space(space)
      add_spaces(new_spaces)
    end
    
    def spaces
      @space_hash.values
    end
    
    def can_contain?(item)
      spaces.any? {|s| s.can_contain?(item)}
    end
    
    private
    
    def delete_space(s)
      @space_hash.delete(s.offsets)
    end
    
    def add_spaces(*new_spaces)
      new_spaces.flatten.each do |s|
        raise InvalidPlacementError, "there is already a space at that location!" if @space_hash.has_key?(s.offsets)
        @space_hash[s.offsets] = s
      end
    end
  end
end