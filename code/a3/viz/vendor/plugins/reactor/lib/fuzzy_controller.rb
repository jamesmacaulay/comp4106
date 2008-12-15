class FuzzyController
  
  attr_reader :plant
  def initialize(plant)
    @plant = plant
    generate_membership_functions
  end
  
  def make_adjustments
    # hot input
    # set restriction high to the degree that plant is a member of temp(hot) and volume(full) and hot_rate(fast)
    #hot_water_restriction = [temp_mf(:hot), volume_mf(:full), hot_rate_mf(:fast)].sum / 3.0
    hot_water_restriction = [temp_mf(:hot), volume_mf(:full), hot_rate_mf(:fast)].max
    plant.hot_water_restriction = hot_water_restriction
    
    # cold input
    # set restriction high to the degree that plant is a member of temp(cold) and volume(full) and cold_rate(fast)
    #cold_water_restriction = [temp_mf(:cold), volume_mf(:full), cold_rate_mf(:fast)].sum / 3.0
    cold_water_restriction = [temp_mf(:cold), volume_mf(:full), cold_rate_mf(:fast)].min
    plant.cold_water_restriction = cold_water_restriction
    
    # drain
    # set restriction high to the degree that the plant is a member of volume(half_full) and
    # not(volume(full)) and average of (hot_rate(fast) and cold_rate(fast)) and not(temp(perfect))
    
    # (we want to replace water quickly if temperature is bad in either way)
    
    # if we're at volume(perfect) and temp(perfect), then we want to make the drain restriction
    # such that input == output
    max_drain = plant.max_drain
    base_target_drain = (plant.hot_water_rate * (1.0 - hot_water_restriction)) + (plant.cold_water_rate * (1.0 - cold_water_restriction))
    
    base_target_restriction = [[(1.0 - (base_target_drain / max_drain.to_f)), 0.0].max, 1.0].min
    
    #plant.drain_restriction = [base_target_restriction, [volume_mf(:half_full), (1.0 - volume_mf(:full)), (1.0 - temp_mf(:perfect))].sum / 3.0].sum / 2.0
    # avg_base_and_temp_mf = [base_target_restriction, (1.0 - temp_mf(:perfect))].sum / 2.0
    # plant.drain_restriction = [volume_mf(:half_full), (1.0 - volume_mf(:full)), avg_base_and_temp_mf].sum / 3.0
    # plant.drain_restriction = [base_target_restriction * 2, [volume_mf(:half_full) * 2, (1.0 - volume_mf(:full)) * 2, (1.0 - temp_mf(:perfect))].sum / 5.0].sum / 3.0
    plant.drain_restriction = [base_target_restriction, [volume_mf(:half_full), (1.0 - volume_mf(:full)), (1.0 - temp_mf(:perfect))].sum / 3.0].sum / 2.0
  end
  
  
  def temp_mf(sym, temp = nil)
    @mfs[:temp][sym][temp || plant.temp]
  end
  
  def volume_mf(sym, vol = nil)
    @mfs[:volume][sym][vol || plant.volume_percentage]
  end
  
  def hot_rate_mf(sym,rate = nil)
    @mfs[:hot_rate][sym][rate || plant.hot_water_rate]
  end
  
  def cold_rate_mf(sym,rate = nil)
    @mfs[:cold_rate][sym][rate || plant.cold_water_rate]
  end
  
  private
  
  def generate_membership_functions
    temp_min = plant.temp_range.min.to_f
    temp_max = plant.temp_range.max.to_f
    temp_mid = (temp_min + temp_max) / 2.0
    temp_half_scale = (temp_max - temp_min) / 2.0
    
    # working with percentages
    volume_max = 100.0
    volume_min = 50.0
    volume_mid = volume_max / 2.0
    volume_half_scale = (volume_max - volume_min) / 2.0
    
    hot_rate_max = plant.rate_ranges[:hot_water][:max].to_f
    hot_rate_min = plant.rate_ranges[:hot_water][:min].to_f
    hot_rate_mid = (hot_rate_max + hot_rate_min) / 2.0
    hot_rate_half_scale = (hot_rate_max - hot_rate_min) / 2.0
    
    cold_rate_max = plant.rate_ranges[:cold_water][:max].to_f
    cold_rate_min = plant.rate_ranges[:cold_water][:min].to_f
    cold_rate_mid = (cold_rate_max + cold_rate_min) / 2.0
    cold_rate_half_scale = (cold_rate_max - cold_rate_min) / 2.0
    
    @mfs = {
      :temp => {
        :hot => lambda {|t| if t >= temp_max then 1.0 elsif t <= temp_mid then 0.0 else (t - temp_mid) / temp_half_scale end},
        :perfect => lambda {|t| if t >= temp_max or t <= temp_min then 0.0 elsif t == temp_mid then 1.0 else 1.0 - ((t - temp_mid).abs / temp_half_scale) end},
        :cold => lambda {|t| if t <= temp_min then 1.0 elsif t >= temp_mid then 0.0 else (t - temp_min) / temp_half_scale end}
      },
      :volume => {
        :full => lambda {|t| if t >= volume_max then 1.0 elsif t <= volume_mid then 0.0 else (t - volume_mid) / volume_half_scale end},
        :perfect => lambda {|t| if t >= volume_max or t <= volume_min then 0.0 elsif t == volume_mid then 1.0 else 1.0 - ((t - volume_mid).abs / volume_half_scale) end},
        :half_full => lambda {|t| if t <= volume_min then 1.0 elsif t >= volume_mid then 0.0 else (t - volume_min) / volume_half_scale end}
      },
      :hot_rate => {
        :fast => lambda {|t| if t >= hot_rate_max then 1.0 elsif t <= hot_rate_mid then 0.0 else (t - hot_rate_mid) / hot_rate_half_scale end},
        :medium => lambda {|t| if t >= hot_rate_max or t <= hot_rate_min then 0.0 elsif t == hot_rate_mid then 1.0 else 1.0 - ((t - hot_rate_mid).abs / hot_rate_half_scale) end},
        :slow => lambda {|t| if t <= hot_rate_min then 1.0 elsif t >= hot_rate_mid then 0.0 else (t - hot_rate_min) / hot_rate_half_scale end}
      },
      :cold_rate => {
        :fast => lambda {|t| if t >= cold_rate_max then 1.0 elsif t <= cold_rate_mid then 0.0 else (t - cold_rate_mid) / cold_rate_half_scale end},
        :medium => lambda {|t| if t >= cold_rate_max or t <= cold_rate_min then 0.0 elsif t == cold_rate_mid then 1.0 else 1.0 - ((t - cold_rate_mid).abs / cold_rate_half_scale) end},
        :slow => lambda {|t| if t <= cold_rate_min then 1.0 elsif t >= cold_rate_mid then 0.0 else (t - cold_rate_min) / cold_rate_half_scale end}
      }
    }
  end
  
end