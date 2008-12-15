module Packing
  class Container
    attr_reader :cost, :id, :spaces
    def initialize(options={})
      raise ArgumentError, "requires a :cost" unless options[:cost] && options[:cost].is_a?(Numeric)
      raise ArgumentError, "requires an :id" unless options[:id]
      @cost = options[:cost]
      @id = options[:id]
      super
    end
  end
end