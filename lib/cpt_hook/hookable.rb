# frozen_string_literal: true

require 'delegate'

module CptHook
# A class for extending other classes / modules with before / after hooks.
#
  class Hookable < SimpleDelegator
    def initialize(obj, method_hooks, additional_contexts = [])
      super(obj)

      additional_contexts = [additional_contexts] unless additional_contexts.is_a?(Array)
      _add_hooks(:before, method_hooks, additional_contexts)
      _add_hooks(:after, method_hooks, additional_contexts)

      method_hooks.hooked_methods.each do |method|
        define_singleton_method(method) do |*args, &block|
          self.send("before_#{method}") if self.respond_to? "before_#{method}"
          val = super(*args, &block)
          self.send("after_#{method}") if self.respond_to? "after_#{method}"
          val
        end
      end
    end

    def class
      __getobj__.class
    end

    private

    def _add_hooks(which, method_hooks, additional_contexts)
      method_hooks.hooks(which).each do |hook|
        define_singleton_method("#{which}_#{hook.method}") do |*args, &block|
          hook.call_chain.each do |call_chain|
            call_args = call_chain.with.map { |ca| ca == :self ? self : ca }
            if call_chain.method.is_a?(Proc)
              call_chain.method.call(*call_args)
            else
              contexts = hook.contexts.concat(additional_contexts).unshift(__getobj__)
              context = contexts.find {|c| c.respond_to?(call_chain.method)}
              raise "No context found for #{which} hook: #{call_chain.method}" unless context
              context.send(call_chain.method, *call_args)
            end
          end
        end
      end
    end
  end
end
