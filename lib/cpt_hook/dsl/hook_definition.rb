module CptHook

  module DSL

    class HookDefinition
      attr_reader :method, :hook_type, :call_chain

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
        @call_chain.last.with(*args)
        self
      end

      def using(*args)
        @call_chain.last.using(*args)
        self
      end

      def contexts(*args)
        @call_chain.last.contexts(*args)
        self
      end

      def merge!(other)
        other.call_chain.each do |cc|
          @call_chain << cc unless @call_chain.any? { |c| c.method == cc.method }
        end
        self
      end
    end
  end
end
