module Tree
  class TreeNode
    def printTree(level = 0)

      if isRoot?
        #print "*"
        puts " determine #{content}"
      else
        #print "|" unless parent.isLastSibling?
        print(' ' * (level) * 4)
        #print(isLastSibling? ? "+" : "|")
        #print "---"
        #print(hasChildren? ? "+" : ">")
        if content
          puts " {#{parent.content}: #{name}} -> determine #{content}"
        else
          puts " {#{parent.content}: #{name}}"
        end
      end


      children { |child| child.printTree(level + 1)}
    end
  end
end