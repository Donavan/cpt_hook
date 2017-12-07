module CptHook
  module DSL
    class MethodCall
      attr_reader :method, :with, :contexts

      def initialize(method_to_call)
        @method = method_to_call
        @contexts = []
        @with = []
      end

      def with(*args)
        @with = args
      end

      def using(*args)
        @contexts = args
      end
    end
  end
end
