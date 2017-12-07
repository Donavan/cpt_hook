module CptHook
  module DSL
    class HookDefinitions

      def initialize
        @hooks = []
      end

      def hooks(hook_type = nil)
        hook_type.nil? ? @hooks : @hooks.select { |h| h.hook_type == hook_type }
      end

      def hooked_methods
        @hooks.map { |h| h.method }.uniq
      end

      def before(method_to_hook, &block)
        _hook_definition(method_to_hook, :before, &block)
      end

      def after(method_to_hook, &block)
        _hook_definition(method_to_hook, :after, &block)
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