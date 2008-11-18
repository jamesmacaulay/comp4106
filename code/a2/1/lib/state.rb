class State
  A,B,C,D,E,LAMP = %w{A B C D E *}
  PEOPLE = Set.new([A,B,C,D,E])
  OBJECTS = Set.new(PEOPLE + [LAMP])
  PEOPLE_SPEED = {A => 1, B => 3, C => 6, D => 8, E => 12}
  attr_reader :objects_near, :time_left
  
  def initialize(objects_near = nil, time_left = 30)
    objects_near ||= OBJECTS
    objects_near = Set.new(objects_near.map(&:to_s))
    raise ArgumentError.new("Invalid objects") unless (objects_near - OBJECTS).empty?
    @objects_near, @time_left = objects_near, time_left
  end
  
  def ==(other)
    self.objects_near == other.objects_near && self.time_left == other.time_left
  end
  
  def eql?(other)
    other.is_a?(State) && self==other
  end
  
  def equal?(other)
    self.eql?(other) && self.hash == other.hash
  end
  
  def hash
    [near_array,time_left].hash
  end
  
  def near_array
    objects_near.to_a.sort
  end
  
  def objects_far
    @objects_far ||= OBJECTS - objects_near
  end
  
  def people_near
    @people_near ||= objects_near & PEOPLE
  end
  
  def people_far
    @people_far ||= objects_far & PEOPLE
  end
  
  def lamp_near?
    objects_near.include?(LAMP)
  end
  
  def objects
    @objects ||= [objects_near, objects_far]
  end
  
  def lamp_index
    @lamp_index ||= lamp_near? ? 0 : 1
  end
  
  def source
    @source ||= lamp_near? ? people_near : people_far
  end
  
  def goal_state?
    objects_near.empty?
  end
  
  def has_near?(obj)
    objects_near.include?(obj)
  end
  
  def to_s(sym=nil)
    case sym
    when nil
      to_s(:near) + ("=" * 24) + to_s(:far) + " time left: #{time_left}"
    when :near
      "%18s" % near_array.inspect.gsub(/"/,'')
    when :far
      "%-18s" % objects_far.to_a.sort.inspect.gsub(/"/,'')
    end
  end
  
  def possible_moves
    @possible_moves ||= begin
      moves = Set.new
      source.each do |p1|
        begin
          moves << Move.new(self,Set.new([p1]))
        rescue
        end
        source.each do |p2|
          begin
            moves << Move.new(self,Set.new([p1,p2]))
          rescue
          end
        end
      end
      moves
    end
  end
  
  def self.time_taken_by_person(person)
    PEOPLE_SPEED[person]
  end
end