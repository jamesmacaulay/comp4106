#from http://rubyquiz.com/quiz40.html, with modifications

class Heap
    def initialize( *elements, &comp )
        @heap = [nil]
        @comp = comp || lambda { |p, c| p <=> c }

        insert(*elements)
    end

    def clear(  )
        @heap = [nil]
    end

    def extract(  )
        case size
        when 0
            nil
        when 1
            @heap.pop
        else
            extracted = @heap[1]
            @heap[1]  = @heap.pop
            sift_down
            extracted
        end
    end

    def insert( *elements )
        elements.each do |element|
            @heap << element
            sift_up
        end
    end

    def size(  )
        @heap.size - 1
    end

    def inspect(  )
        @heap[1..-1].inspect
    end

    def to_s(  )
        # Write this!
    end
    
    def include?(element)
      @heap.include?(element)
    end

    private

    def sift_down(  )
        i = 1
        loop do
            c = 2 * i
            break if c >= @heap.size

            c += 1 if c + 1 < @heap.size and @comp[@heap[c + 1], @heap[c]] < 0
            break if @comp[@heap[i], @heap[c]] <= 0

            @heap[c], @heap[i] = @heap[i], @heap[c]
            i = c
        end
    end

    def sift_up(  )
        i = @heap.size - 1
        until i == 1
            p = i / 2
            break if @comp[@heap[p], @heap[i]] <= 0

            @heap[p], @heap[i] = @heap[i], @heap[p]
            i = p
        end
    end
end