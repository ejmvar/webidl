module WebIDL
  module ParseTree
    class Attribute < Treetop::Runtime::SyntaxNode

      def build
        raise NotImplementedError
      end

    end # Attribute
  end # ParseTree
end # WebIDL