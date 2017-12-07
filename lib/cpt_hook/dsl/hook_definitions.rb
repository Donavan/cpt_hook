module CptHook
  module DSL
    class HookDefinitions
      attr_reader :hooks

      def initialize
        @hooks = []
      end

      def before(method_to_hook, &block)
        _hook_definition(method_to_hook, :before)
      end

      def after(method_to_hook, &block)
        _hook_definition(method_to_hook, :after)
      end

      private

      def _hook_definition(method_to_hook, hook_type, &block)
        hook_def = HookDefinition.new(method_to_hook, hook_type)
        @hooks << hook_def
        hook_def.instance_eval(&block) if block_given?
        hook_def
      end
    end
  end
end