module CptHook
  module DSL
    class MethodCall
      attr_reader :method, :withs, :contexts

      def initialize(method_to_call)
        @method = method_to_call
        @contexts = []
        @withs = []
      end

      def resolve_with(&block)
        @withs.map!(&block)
      end

      def resolve_contexts(&block)
        @contexts.map!(&block)
      end

      def with(*args)
        @withs = args
      end

      def using(*args)
        @contexts = args
      end

      def clone(other)
        @withs = other.withs.dup
        @contexts = other.contexts.dup
        self
      end

      def dup
        MethodCall.new(@method).clone(self)
      end
    end
  end
end
