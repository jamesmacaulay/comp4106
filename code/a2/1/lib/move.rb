class Move
  attr_reader :initial_state, :travellers
  
  def initialize(initial_state, travellers)
    travellers = Set.new(travellers.map(&:to_s))
    @initial_state,@travellers = initial_state,travellers
    unless valid?
      #debugger
      raise ArgumentError.new("Invalid move from state:\n#{initial_state}\n#{travellers.inspect}\n")
    end
  end
  
  def ==(other)
    self.initial_state == other.initial_state && self.travellers == other.travellers
  end
  
  def eql?(other)
    other.is_a?(Move) && self==other
  end
  
  def equal?(other)
    self.eql?(other) && self.hash == other.hash
  end
  
  def hash
    ["Move","initial_state", initial_state.hash, "travellers", travellers.hash].hash
  end
  
  def target_state
    @target_state ||= begin
      target_objects_near = initial_state.objects_near
      moving_things = travellers + [State::LAMP]
      if initial_state.lamp_near?
        target_objects_near -= moving_things
      else
        target_objects_near += moving_things
      end
      State.new(target_objects_near, initial_state.time_left - time_spent)
    end
  end
  
  def time_spent
    travellers.map {|t| State.time_taken_by_person(t)}.max
  end
  
  def to_s
    @str ||= begin
      middle_bit = (travellers.to_a + [State::LAMP]).inspect.gsub(/"/,'')
      length = 24 - middle_bit.length
      dir = initial_state.lamp_near? ? '>' : '<'
      target_state.to_s(:near) + (dir * (length / 2)) + middle_bit + (dir * (length / 2.0).ceil) + initial_state.to_s(:far) + " time left: #{target_state.time_left}"
    end
  end
  
  def valid?
    return false unless [1,2].include?(travellers.size)
    travellers.each do |t|
      return false if initial_state.lamp_near? ^ initial_state.has_near?(t)
    end
    return false if initial_state.time_left < time_spent
    return true
  end
  
end