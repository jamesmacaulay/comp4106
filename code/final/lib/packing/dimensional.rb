module Packing
  module Dimensional
    
    # meant to be overridden
    def empty?
      true
    end
    # meant to be overridden
    def weight
      0
    end
    
    def measurements
      @measurements.dup
    end
    
    def arity
      @arity ||= @measurements.size
    end
    
    def volume
      @volume ||= (@measurements.inject(1) {|product,m| product *= m})
    end
    
    # assume grams for weight and mm for measurements
    def volumetric_weight(options={})
      # 4D, 5D volumetric weights? what is the density of water in 14D??
      @volumetric_weight ||= volume.to_f / (6 * (10 ** arity))
    end
  end
end