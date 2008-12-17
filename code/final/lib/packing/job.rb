module Packing
  class Job
    include Validations
    
    # :container_templates -- an array of containers (each represents an infinite supply of containers of those specifications)
    # :items -- an array of items to be packed
    def initialize(options={})  
      @items_can_fit_in_containers = {}
      @containers_can_contain_items = {}
      @container_weights = {}
      @total_unpacked_item_weight = {}
      @total_unpacked_item_volume = {}
      
      @container_templates = validate_spaces(options[:containers], :name => ':container_templates', :class => Container).map {|item| item.dup}
      @containers = []
      @original_items = validate_spaces(options[:items].sort, :class => Item).map {|item| item.dup}
      @unpacked_items = @original_items.map {|item| item.dup}
      @packed_items = []
      @abandoned_items = []
    end
    
    def dup
      self.class.new(:containers => container_templates, :items => original_items)
    end
    
    def finished?
      @unpacked_items.empty?
    end
    
    def container_templates
      @container_templates.dup
    end
    
    def containers
      @containers.dup
    end
    
    def unpacked_items
      @unpacked_items.dup
    end
    
    def abandoned_items
      @abandoned_items.dup
    end
    
    def original_items
      @original_items.dup
    end
    
    def spaces
      ary = []
      @containers.each {|c| c.spaces.each {|s| ary << s}}
      ary
    end
    
    def biggest_unpacked_item
      @unpacked_items.last
    end
    
    def optimal_unpacked_item(&block)
      optimal = @unpacked_items.first
      @unpacked_items.each {|i| optimal = i if (optimal.nil? || yield(optimal,i))}
      optimal
    end
    
    def optimal_space_for_item(item,&block)
      ary = spaces
      optimal = nil
      ary.each do |s|
        debugger if s.container.nil?
        optimal = s if s.can_contain?(item) && yield(optimal,s,item)
      end
      optimal
    end
    
    def optimal_container(&block)
      optimal = @container_templates.first
      @container_templates.each {|c| optimal = c if container_can_contain_something?(c) && yield(optimal,c)}
      optimal
    end
    
    def take_container(container_index)
      puts "taking container"
      container = container_index.is_a?(Container) ? container_index : @container_templates[container_index]
      @containers << container.dup
    end
    
    def place_item_in_space(item_index,space,&block)
      puts "placing item in space"
      place_item_in_space!(item_index,space,&block)
    rescue InvalidPlacementError
      nil
    end
    
    def place_item_in_space!(item_index,space,&block)
      item = item_index.is_a?(Item) ? item_index : @unpacked_items[item_index]
      item_index = item_index.is_a?(Item) ? @unpacked_items.index(item_index) : item_index
      debugger unless space.empty?
      space.container.place_item_in_space!(item,space,&block)
      @unpacked_items.delete_at(item_index)
      @packed_items << item
    end
    
    def abandon_item(item_index)
      index = item_index.is_a?(Item) ? @unpacked_items.index(item_index) : item_index
      @abandoned_items << @unpacked_items.delete_at(index)
    end
    
    def total_unpacked_item_weight
      unpacked_item_count = @unpacked_items.size
      @total_unpacked_item_weight[unpacked_item_count] ||= @unpacked_items.sum(&:weight)
    end
    
    def total_unpacked_item_volume
      unpacked_item_count = @unpacked_items.size
      @total_unpacked_item_volume[unpacked_item_count] ||= @unpacked_items.sum(&:volume)
    end
    
    def container_weight(container)
      #debugger if container.nil?
      unpacked_item_count = @unpacked_items.size
      @container_weights[unpacked_item_count] ||= {}
      hash = @container_weights[unpacked_item_count]
      key = container.measurements.sort.inspect
      if hash.has_key?(key)
        return hash[key]
      end
      #debugger if container.weight.nil?
      hash[key] = container.weight
    end
    
    def container_can_contain_something?(container)
      unpacked_item_count = @unpacked_items.size
      @containers_can_contain_items[unpacked_item_count] ||= {}
      hash = @containers_can_contain_items[unpacked_item_count]
      key = container.measurements.sort.inspect
      if hash.has_key?(key)
        return @containers_can_contain_items[key]
      end
      hash[key] = @unpacked_items.any? {|i| container.can_contain?(i)}
    end
    
    def item_can_fit_somewhere?(item_index)
      item = item_index.is_a?(Item) ? item_index : @unpacked_items[item_index]
      item_key = item.measurements.sort.inspect
      if @items_can_fit_in_containers.has_key?(item_key)
        return @items_can_fit_in_containers[item_key]
      end
      @items_can_fit_in_containers[item_key] = @container_templates.any? {|c| c.can_contain?(item)}
    end
  end
end