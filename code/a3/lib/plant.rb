class Plant
  attr_reader :max_core_heating, :max_volume, :time, :temp_range, :temp, :volume, :controller
  alias_method :n, :max_core_heating
  alias_method :x, :max_volume
  
  def initialize(options = {})
    options.reverse_merge!( :max_core_heating      => 10,
                            :max_volume            => 1000,
                            :temp_range            => 10..70,
                            :volume                => 750,
                            :temp                  => 30 )
                            
    @max_core_heating = options[:max_core_heating]
    @max_volume       = options[:max_volume]
    @temp_range       = options[:temp_range]
    @rate_ranges = { :hot_water => 1..10, :cold_water => 1..10, :core_heating => 0..@max_core_heating }
    @history          = []
    @history          << { :temp   => options[:temp],
                           :volume => options[:volume],
                           :rates  => { :hot_water    => new_rate(:hot_water),
                                        :cold_water   => new_rate(:cold_water),
                                        :core_heating => new_rate(:core_heating)},
                           :restrictions => { :hot_water => 0.0, :cold_water => 0.0, :drain => 0.0 }}
    @controller = FuzzyController.new(self)
  end
  
  ### usable by FuzzyController#adjust
  
  def volume_percentage
    volume.to_f / @max_volume * 100
  end
  
  def hot_water_rate
    rate(:hot_water)
  end
  
  def cold_water_rate
    rate(:cold_water)
  end
  
  def temp
    @history.empty? ? nil : @history.last[:temp]
  end
  
  def cold_water_restriction=(val)
    @history.last[:restrictions] ||= {}
    @history.last[:restrictions][:cold_water] = val
  end
  
  def hot_water_restriction=(val)
    @history.last[:restrictions] ||= {}
    @history.last[:restrictions][:hot_water] = val
  end
  
  def drain_restriction=(val)
    @history.last[:restrictions] ||= {}
    @history.last[:restrictions][:drain] = val
  end
  
  ####
  
  def volume
    @history.empty? ? nil : @history.last[:volume]
  end
  
  def rate(sym)
    return 15.0 if sym == :drain
    @history.empty? ? nil : @history.last[:rates][sym]
  end
  
  def restricted_rate(sym)
    debugger if rate(sym).nil? or restriction(sym).nil?
    rate(sym) * restriction(sym)
  end
  
  def restriction(sym)
    @history.empty? ? nil : @history.last[:restrictions][sym]
  end
  
  def history
    Marshal.load(Marshal.dump(@history))
  end
  
  def increment_time
    new_volume = volume - restricted_rate(:drain) + restricted_rate(:cold_water) + restricted_rate(:hot_water)
    raise StandardError, "Too little water left in tank!" if new_volume < (max_volume.to_f / 2)
    
    new_temp = ((5 * restricted_rate(:cold_water)) + (95 * restricted_rate(:hot_water)) + (temp * (volume - restricted_rate(:drain)))) / new_volume + rate(:core_heating)
    raise StandardError, "Tank is too hot!" if new_temp > temp_range.max
    raise StandardError, "Tank is too cold!" if new_temp < temp_range.min
    
    @history << {
      :temp => new_temp,
      :volume => new_volume,
      :rates  => { :hot_water    => new_rate(:hot_water),
                   :cold_water   => new_rate(:cold_water),
                   :core_heating => new_rate(:core_heating)}
    }
    p @history.last
  end
  
  private
  
  def new_rate(sym)
    rng = @rate_ranges[sym]
    min,max = rng.min, rng.max
    prev = rate(sym)
    rnd = random_within_range(rng)
    if @history.empty?
      return rnd
    else
      prevprev = (@history.length == 1) ? prev : @history[-2][:rates][sym]
      accel = prev - prevprev
      max_diff = [(max - prev).abs, (min - prev).abs].max
      mod = 2.0 - (max_diff.zero? ? 0 : (accel / max_diff))
      rel = rnd - prev
      result = rel * rel.abs / (max_diff * mod) + prev
      return result
    end
  end
  
  def random_within_range(rng)
    rand * (rng.max - rng.min) + rng.min
  end
  
end