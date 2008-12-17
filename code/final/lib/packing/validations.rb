module Packing
  module Validations
    def validate_measurements(these_measurements, options={})
      raise ArgumentError, (options[:message] || "requires a proper array of #{options[:name] || ":measurements"}") unless (options[:allow_nil] && these_measurements.nil?) || (these_measurements && these_measurements.is_a?(Array) && these_measurements.any? && these_measurements.all? {|m| m.is_a?(Numeric) && m > 0})
      these_measurements
    end
  
    def validate_offsets(these_offsets, options={})
      klass = options[:class]
      raise ArgumentError, (options[:message] || "#{options[:name] || ":offsets"} must be a proper array of offsets") unless (options[:allow_nil] && these_offsets.nil?) || (these_offsets && these_offsets.is_a?(Array) && these_offsets.size == arity && these_offsets.all? {|o| o.is_a?(Numeric) && o >= 0})
      these_offsets
    end
  
    def validate_spaces(these_spaces, options={})
      klass = options[:class] || Space
      raise ArgumentError, (options[:message] || "#{options[:name] || (':' + klass.name.downcase.pluralize)} must be a #{klass.name} array") unless (options[:allow_nil] && these_spaces.nil?) || (these_spaces && ((these_spaces.is_a?(Array) && these_spaces.all? {|o| o.is_a?(klass)}) || (these_spaces.is_a?(klass))))
      these_spaces
    end
    
    def validate_whole_number(this_number, options={})
      raise ArgumentError, (options[:message] || "requires a non-negative #{options[:name]}") unless (options[:allow_nil] && this_number.nil?) || (this_number.is_a?(Numeric) && this_number >= 0)
      this_number
    end
  end
end