class FuzzyController
  
  def initialize(plant)
    @plant = plant
    temp_min = plant.temp_range.min.to_f
    temp_max = plant.temp_range.max.to_f
    temp_mid = (temp_min + temp_max) / 2.0
    temp_half_scale = (temp_max - temp_min) / 2.0
    
    volume_max = plant.max_volume.to_f
    volume_min = 0.0
    volume_mid = volume_max / 2.0
    volume_half_scale = (volume_max - volume_min) / 2.0
    
    @mfs = {
      :temp => {
        :hot => lambda {|t| if t >= temp_max then 1.0 elsif t <= temp_mid then 0.0 else (t - temp_mid) / temp_half_scale},
        :luke_warm => lambda {|t| if t >= temp_max or t <= temp_min then 0.0 elsif t == temp_mid then 1.0 else 1.0 - ((t - temp_mid).abs / temp_half_scale) },
        :cold => lambda {|t| if t <= temp_min then 1.0 elsif t >= temp_mid then 0.0 else (t - temp_min) / temp_half_scale }
      },
      :volume => {
        :full => lambda {|t| if t >= volume_max then 1.0 elsif t <= volume_mid then 0.0 else (t - volume_mid) / volume_half_scale},
        :half_full => lambda {|t| if t >= volume_max or t <= volume_min then 0.0 elsif t == volume_mid then 1.0 else 1.0 - ((t - volume_mid).abs / volume_half_scale) },
        :empty => lambda {|t| if t <= volume_min then 1.0 elsif t >= volume_mid then 0.0 else (t - volume_min) / volume_half_scale }
      }
    }
  end
  
  def adjust
    
  end
  
  private
  
  def temp_mf(sym, temp)
    @mfs[:temp][sym][temp]
  end
  
  def volume_mf(sym, vol)
    @mfs[:volume][sym][vol]
  end
  
end