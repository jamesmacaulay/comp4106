class Plant
  attr_reader :max_core_heating, :max_volume, :time, :temp_range, :temp, :volume, :controller, :rate_ranges, :max_drain, :error
  alias_method :n, :max_core_heating
  alias_method :x, :max_volume
  
  def initialize(options = {})
    options.reverse_merge!( :max_core_heating      => 2.0,
                            :max_volume            => 500,
                            :temp_range            => 10..70,
                            :volume                => 375,
                            :temp                  => 30,
                            :max_drain             => 15.0 )
                            
    options[:volume] = 0.75 * options[:max_volume]
    @max_core_heating = options[:max_core_heating]
    @max_volume       = options[:max_volume]
    @temp_range       = options[:temp_range]
    @max_drain        = options[:max_drain]
    @rate_ranges = { :hot_water => {:min => 1, :max => 10}, :cold_water => {:min => 1, :max => 10}, :core_heating => {:min => 0, :max => @max_core_heating} }
    @history          = []
    @history          << { :temp   => options[:temp],
                           :volume => options[:volume],
                           :rates  => { :hot_water    => new_rate(:hot_water),
                                        :cold_water   => new_rate(:cold_water),
                                        :core_heating => new_rate(:core_heating)},
                           :restrictions => { :hot_water => 0.0, :cold_water => 0.0, :drain => 0.0 }}
    @controller = FuzzyController.new(self)
    @error = nil
  end
  
  def start_reactor(limit=10000)
    limit.times do
      increment_time
    end
  rescue StandardError => e
   @error = e
  ensure
    return self
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
    return @max_drain if sym == :drain
    @history.empty? ? nil : @history.last[:rates][sym]
  end
  
  def restricted_rate(sym)
    rate(sym) * (1.0 - restriction(sym))
  end
  
  def restriction(sym)
    @history.empty? ? nil : @history.last[:restrictions][sym]
  end
  
  def history
    Marshal.load(Marshal.dump(@history))
  end
  
  def increment_time
    
    @controller.make_adjustments
    
    #p @history.last
    
    new_volume = volume - restricted_rate(:drain) + restricted_rate(:cold_water) + restricted_rate(:hot_water)
    raise StandardError, "Overfilled! (volume reached #{new_volume})" if new_volume >= max_volume.to_f
    raise StandardError, "Underfilled! (volume reached #{new_volume})" if new_volume < (max_volume.to_f / 2)
    
    new_temp = ((5 * restricted_rate(:cold_water)) + (95 * restricted_rate(:hot_water)) + (temp * (volume - restricted_rate(:drain)))) / new_volume + rate(:core_heating)
    raise StandardError, "Melt-down! (temperature reached #{new_temp})" if new_temp > temp_range.max
    raise StandardError, "Shut-down! (temperature reached #{new_temp})" if new_temp < temp_range.min
    
    @history << {
      :temp => new_temp,
      :volume => new_volume,
      :rates  => { :hot_water    => new_rate(:hot_water),
                   :cold_water   => new_rate(:cold_water),
                   :core_heating => new_rate(:core_heating)}
    }
  end
  
  private
  
  def new_rate(sym)
    min,max = @rate_ranges[sym][:min], @rate_ranges[sym][:max]
    prev = rate(sym)
    rnd = random_within_range(min,max)
    if @history.empty?
      return rnd
    else
      prevprev = (@history.length == 1) ? prev : @history[-2][:rates][sym]
      accel = prev - prevprev
      max_diff = [(max - prev).abs, (min - prev).abs].max
      mod = 2.0 - (max_diff.zero? ? 0 : (accel / max_diff))
      rel = rnd - prev
      result = rel * Math.sqrt(rel.abs) / (max_diff * mod) + prev
      return result
    end
  end
  
  def random_within_range(min,max)
    srand
    rand * (max - min) + min
  end
  
end