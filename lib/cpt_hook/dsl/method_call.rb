module CptHook
  module DSL
    class MethodCall
      attr_reader :method, :args

      def initialize(method_to_call)
        @method = method_to_call
      end

      def with(*args)
        @args = *args
      end
    end
  end
end
