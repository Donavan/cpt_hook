require 'cpt_hook/version'
require 'cpt_hook/hookable'
require 'cpt_hook/dsl'
module CptHook

  def self.define_hooks(&block)
    dsl = DSL::HookDefinitions.new
    dsl.instance_eval(&block) if block_given?
    dsl
  end
end
