module Packing
  class Container
    attr_reader :cost, :id
    def initialize(options={})
      raise ArgumentError, "requires a :cost" unless options[:cost] && options[:cost].is_a?(Numeric) && options[:cost] >= 0
      validate_measurements(options[:measurements])
      raise ArgumentError, "requires an :id" unless options[:id] && (options[:id].is_a?(Numeric) || options[:id].is_a?(String) || options[:id].is_a?(Symbol))
      
      @cost = options[:cost]
      @id = options[:id]
      @spaces = {[0,0,0] => Space.new(options.slice(:measurements))}
    end
    
    def place_item_in_space(item, space, options={})
      place_item_in_space!(item, space, options)
    rescue InvalidPlacementError
      nil
    end
    
    def place_item_in_space!(item, space, options={})
      if options[:force]
        raise InvalidPlacementError, "that item could never fit inside that space" unless space.can_contain?(item)
        
      end
      raise InvalidPlacementError, "that item is not contained by that space" unless space.contains?(item)
      
      new_spaces = space.split_on(item)
      space.overlappers.each do |s|
        new_spaces << s.split_on(item)
        delete_space(s)
      end
      delete_space(space)
      add_spaces(new_spaces)
    end
    
    private
    
    def delete_space(s)
      @spaces.delete(s.offsets)
    end
    
    def add_spaces(*new_spaces)
      new_spaces.flatten.each do |s|
        raise InvalidPlacementError, "there is already a space at that location!" if @spaces.has_key?(s.offsets)
        @spaces[s.offsets] = s
      end
    end
  end
end