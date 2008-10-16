module Tree
  class TreeNode
    def printTree(level = 0)

      if isRoot?
        print "*"
        puts " #{content}"
      else
        print "|" unless parent.isLastSibling?
        print(' ' * (level - 1) * 4)
        print(isLastSibling? ? "+" : "|")
        print "---"
        print(hasChildren? ? "+" : ">")
        puts " {#{parent.content} => #{name}} : #{content}"
      end


      children { |child| child.printTree(level + 1)}
    end
  end
end