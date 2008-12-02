class Plant
  attr_reader :max_core_heating, :max_volume, :time, :min_temp, :max_temp, :temp, :volume
  alias_method :n, :max_core_heating
  alias_method :x, :max_volume
  
  def initialize(options = {})
    options.reverse_merge!( :max_core_heating      => 10,
                            :max_volume            => 1000,
                            :temp_range            => 10..70,
                            :volume                => 100,
                            :temp                  => 30 )
                            
    @max_core_heating = options[:max_core_heating]
    @max_volume       = options[:max_volume]
    @temp_range       = options[:temp_range]
    @history          = []
    @history          << { :temp   => options[:temp],
                           :volume => options[:volume],
                           :rates  => { :hot_water    => new_rate(:hot_water),
                                        :cold_water   => new_rate(:cold_water),
                                        :core_heating => new_rate(:core_heating),
                                        :drain        => 15.0 },
                           :restrictions => { :hot_water => 0.0, :cold_water => 0.0, :drain => 0.0 }}
    
    @rate_ranges = { :hot_water => 1..10, :cold_water => 1..10, :core_heating => 0..@max_core_heating }
  end
  
  def temp
    @history.empty? ? nil : @history.last[:temp]
  end
  
  def volume
    @history.empty? ? nil : @history.last[:volume]
  end
  
  def rate(sym)
    @history.empty? ? nil : @history.last[:rates][sym]
  end
  
  def cold_water_restriction=(val)
    @history.last[:restrictions][:cold_water] = val
  end
  
  def hot_water_restriction=(val)
    @history.last[:restrictions][:hot_water] = val
  end
  
  def drain_restriction=(val)
    @history.last[:restrictions][:drain] = val
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
      rel = rnd - prev
      prevprev = (@history.length == 1) ? prev : @history[-2][:rates][sym]
      accel = prev - prevprev
      max_diff = [(max - prev).abs, (min - prev.abs)].max
      mod = 2.0 - (accell / max_diff)
      return (rel * (rel.abs / [(max - prev).abs, (min - prev.abs)].max * mod)) + prev
    end
  end
  
  def random_within_range(rng)
    rand * (rng.max - rng.min) + rng.min
  end
  
  def increment_time
    new_volume = volume - rate(:drain) + rate(:cold) + rate(:hot)
    new_temp = ((5 * rate(:cold)) + (95 * rate(:hot)) + (temp * (volume - rate(:drain)))) / new_volume + rate(:core_heating)
    @history << {
      :
    }
  end
  
end