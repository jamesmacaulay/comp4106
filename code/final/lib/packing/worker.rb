module Packing
  class Worker
    LAMBDAS = {}
    # optimal is the space which is optimal-so-far
    # return true if "space" is better than "optimal", false otherwise
    LAMBDAS[:pick_space_for_item] = lambda do |optimal, space, item|
      s_scale = @dna[0]
      s_overlappers_scale = @dna[1]
      container_density_scale = @dna[2]
      container_density_threshold = @dna[3]
      
      # water density is (1.0 / (10 ** (arity || 3))) g / mm
      # we'll say max density will never be higher than 10 times density of water
      threshold = container_density_threshold * (10.0 / (10 ** space.arity))
      if (passed_threshold = (comparator1[space] < threshold))
        if optimal.nil?
          true
        else
          comparator1 = lambda do |s|
            (job.container_weight(s.container) / s.container.volume)
          end
          comparator2 = lambda do |s|
            container = s.container
            (s_scale * s.volume) +
            (s_overlappers_scale * s.overlappers.sum(&:volume)) +
            (container_density_scale * comparator1[s])
          end
          (comparator2[space] < comparator2[optimal])
        end
      else
        false
      end
    end
    # pick a container to take next
    LAMBDAS[:pick_container] = lambda do |optimal, container|
      container_weight_scale = @dna[4]
      container_density_scale = @dna[5]
      container_volume_scale = @dna[6]
      
      if optimal.nil?
        true
      else
        comparator1 = lambda do |c|
          weight = job.container_weight(c)
          (weight * container_weight_scale) +
          ((job.container_weight(c) / c.volume) * container_density_scale) +
          (c.volume * container_volume_scale)
        end
        (comparator1[space] < comparator1[optimal])
      end
    end
    
    # manipulate item so that it will be positioned inside space
    LAMBDAS[:rotate_and_move_item_in_space] = lambda do |item, space|
      measurements = item.measurements
      using_integers = measurements.first.eql?(measurements.first.ceil)
      axes = item.axes
      item.arity.times do |variable|
        optimal = axes.first
      end
    end
    
    attr_reader :step, :max_steps, :job
    def initialize(this_job, options={})
      @job = this_job.dup
      @max_steps = options[:max_steps]
      @step = 0
      @dna = options[:dna] || random_dna
      @lambdas = LAMBDAS.merge(@dna)
    end
    
    def random_dna
      result = []
      3.times {result << rand(0)}
      result
    end
    
    def perform_job
      until job.finished? #or @step >= @max_steps
        #@step += 1
        item = pick_item
        if job.item_can_fit_somewhere?(item)
          if space = pick_space_for_item(item)
            place_item_in_space(item,space)
          else
            container = pick_container
            job.take_container(container)
          end
        else
          job.abandon_item(item)
        end
      end
      job
    end
    
    protected
    
    def pick_item
      job.biggest_item
    end
    
    def pick_container
      job.optimal_container(&(@lambdas[:pick_container]))
    end
    
    def pick_space_for_item(item)
      job.optimal_space_for_item(item, &(@lambdas[:pick_space_for_item]))
    end
    
    def place_item_in_space(item,space)
      job.place_item_in_space!(item, space, &(@lambdas[:rotate_and_move_item_in_space]))
    end
    
    
  end
end