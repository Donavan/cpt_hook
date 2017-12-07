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

      def merge!(other)
        other.hooks.each do |hook|
          my_hook = @hooks.find { |h| (h.method == hook.method) && (h.hook_type == hook.hook_type) }
          if my_hook
            my_hook.merge!(hook)
          else
            @hooks << hook
          end
        end
        self
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