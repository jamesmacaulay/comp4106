module Packing
  module Validations
    def validate_measurements(these_measurements, options={})
      raise ArgumentError, ("requires a proper array of :measurements" % (options[:name] || ":measurements")) unless (these_measurements || options[:allow_nil]) && these_measurements.is_a?(Array) && these_measurements.any? && these_measurements.all? {|m| m.is_a?(Numeric) && m > 0}
      these_measurements
    end
  
    def validate_offsets(these_offsets, options={})
      raise ArgumentError, ("%s must be a proper array of offsets" % (options[:name] || ":offsets")) unless (these_offsets || options[:allow_nil]) && (these_offsets.is_a?(Array) && these_offsets.size == arity && these_offsets.all? {|o| o.is_a?(Numeric) && o >= 0})
      these_offsets
    end
  
    def validate_spaces(these_spaces, options={})
      raise ArgumentError, ("%s must be an array of other spaces" % (options[:name] || ":spaces")) unless these_spaces.nil? || these_spaces.is_a?(Array) && these_spaces.all? {|o| o.is_a?(Space)}
      these_spaces
    end
  end
end