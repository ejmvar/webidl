module WebIDL
  module Ast
    class TypeDef < Node

      attr_reader :type, :name

      def initialize(parent, type, name)
        @parent = parent
        @type   = type
        @name   = name
      end

    end # TypeDef
  end # Ast
end # WebIDL