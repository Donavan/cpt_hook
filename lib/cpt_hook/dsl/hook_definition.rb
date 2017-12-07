module CptHook

  module DSL

    class HookDefinition
      attr_reader :method, :hook_type

      def initialize(method_to_hook, type)
        @method     = method_to_hook
        @hook_type  = type
        @call_chain = []
      end

      def call(method_to_call)
        @call_chain << MethodCall.new(method_to_call)
        self
      end

      def with(*args)
        @call_chain.last.with(args)
        self
      end
    end
  end
end