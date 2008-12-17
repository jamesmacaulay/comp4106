module Packing
  class Worker
    
    attr_reader :job
    def initialize(this_job, options={})
      @job = this_job.dup
      @dna = options[:dna] || random_dna
      initialize_lambdas
    end
    
    def dna
      @dna.dup
    end
    
    def random_dna
      srand
      result = []
      8.times {result << ((rand(0) - 0.5) * 2)}
      result
    end
    
    def perform_job
      until job.finished? #or @step >= @max_steps
        #@step += 1
        item = pick_item
        #debugger
        if job.item_can_fit_somewhere?(item)
          if space = pick_space_for_item(item)
            debugger unless space.empty?
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
      job.biggest_unpacked_item
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
    
    def initialize_lambdas
      @lambdas = {}
      # optimal is the space which is optimal-so-far
      # return true if "space" is better than "optimal", false otherwise
      @lambdas[:pick_space_for_item] = lambda do |optimal, space, item|
        s_scale = @dna[0]
        s_overlappers_scale = @dna[1]
        container_density_scale = @dna[2]
        container_density_threshold = @dna[3]
      
        comparator1 = lambda do |s|
          #debugger if s.container.nil?
          (job.container_weight(s.container) / s.container.volume)
        end
        # water density is (1.0 / (10 ** (arity || 3))) g / mm
        # we'll say max density will never be higher than 10 times density of water
        threshold = (container_density_threshold / 2 + 0.5) * (10.0 / (10 ** space.arity))
        if (passed_threshold = (comparator1[space] < threshold))
          if optimal.nil?
            true
          else
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
      @lambdas[:pick_container] = lambda do |optimal, container|
        container_weight_scale = @dna[4]
        container_density_scale = @dna[5]
        container_volume_scale = @dna[6]
      
        if optimal.nil?
          true
        else
          comparator1 = lambda do |c|
            weight = job.container_weight(c)
            debugger if weight.nil?
            (weight * container_weight_scale) +
            ((weight / c.volume) * container_density_scale) +
            (c.volume * container_volume_scale)
          end
          (comparator1[container] < comparator1[optimal])
        end
      end
    
      # manipulate item so that it will be positioned inside space
      @lambdas[:rotate_and_move_item_in_space] = lambda do |item, space|
        measurements = item.measurements
        space_measurements = space.measurements
        using_integers = measurements.first.eql?(measurements.first.ceil)
        
        
        axes = item.axes
        axes_for_offsets = item.axes
        mapping = []
        item.arity.times do |space_axis|
          linear_space = space_measurements[space_axis]
          comparator1 = lambda do |axis|
            debugger if linear_space.nil? or measurements[axis].nil? or @dna[7].nil?
            (measurements[axis] / linear_space.to_f) * @dna[7]
          end
          optimal_axis = 0
          axes.each do |item_axis|
            unless linear_space < measurements[item_axis]
              if linear_space < measurements[optimal_axis] || comparator1[item_axis] > comparator1[optimal_axis]
                optimal_axis = item_axis
              end
            end
          end
          mapping << axes.delete(optimal_axis)
          debugger if mapping.last.nil?
          puts 'debugged'
        end
        item.rotate(mapping)
        item.place_at_offsets(space.offsets)
      end
      
    end
  end
end