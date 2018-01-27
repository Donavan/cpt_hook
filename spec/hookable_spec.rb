require 'pry'
RSpec.describe CptHook::Hookable do

  before(:each) do
    @obj_to_wrap = double
    allow(@obj_to_wrap).to receive(:some_fn)
    allow(@obj_to_wrap).to receive(:local_fn)
    allow(@obj_to_wrap).to receive(:other_local_fn)
  end


  it "adds before hooks" do
    hooks = CptHook::define_hooks do
      before(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(wrapped).to respond_to(:before_some_fn)
  end

  it "adds after hooks" do
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(wrapped).to respond_to(:after_some_fn)
  end

  it "allows both before and after hooks on the same function" do
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn)
      before(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(wrapped).to respond_to(:before_some_fn)
    expect(wrapped).to respond_to(:after_some_fn)
  end

  it "it calls the hook functions when the wrapped function is called" do
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(wrapped).to receive(:after_some_fn)
    wrapped.some_fn
  end

  it "it calls methods on the wrapped object during hooks" do
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(@obj_to_wrap).to receive(:local_fn)
    wrapped.some_fn
  end

  it "it impersonates the wrapped object" do
    class Foo; end
    foo = Foo.new
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(foo, hooks)
    expect(wrapped.class).to eq(Foo)
  end

  it "can call multiple functions in a hook" do
    hooks = CptHook::define_hooks do
      before(:some_fn).call(:local_fn)
                      .call(:other_local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(@obj_to_wrap).to receive(:local_fn)
    expect(@obj_to_wrap).to receive(:other_local_fn)
    wrapped.some_fn
  end

  it "it passes arguments to hook functions" do
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn).with(42)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(@obj_to_wrap).to receive(:local_fn).with(42)
    wrapped.some_fn
  end

  it "it accepts procs as hook functions" do
    external = double
    allow(external).to receive(:external_fn)

    hooks = CptHook::define_hooks do
      after(:some_fn).call(lambda { | obj | obj.external_fn(42) }).with(external)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(external).to receive(:external_fn).with(42)
    wrapped.some_fn
  end

  it "it passes wrapped object to hook functions via magic symbol" do
    hooks = CptHook::define_hooks do
      after(:some_fn).call(:local_fn).with(:self)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(@obj_to_wrap).to receive(:local_fn).with(@obj_to_wrap)
    wrapped.some_fn
  end

  it "it can call methods on the on external contexts during hooks via external contexts in the initializer" do
    external = double
    allow(external).to receive(:external_fn)

    hooks = CptHook::define_hooks do
      after(:some_fn).call(:external_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks, external)
    expect(external).to receive(:external_fn)
    wrapped.some_fn
  end

  it "it can call methods on the on external contexts during hooks via external contexts in the dsl" do
    external = double
    allow(external).to receive(:external_fn)

    hooks = CptHook::define_hooks do
      after(:some_fn).call(:external_fn)
      .contexts(external)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(external).to receive(:external_fn)
    wrapped.some_fn
  end

  it "it can call methods on the on external contexts during hooks via using" do
    external = double
    allow(external).to receive(:external_fn)

    hooks = CptHook::define_hooks do
      after(:some_fn).call(:external_fn).using(external)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks)
    expect(external).to receive(:external_fn)
    wrapped.some_fn
  end

  it "has hook defitions that can be merged" do
    external = double
    allow(external).to receive(:external_fn)

    hooks = CptHook::define_hooks do
      after(:some_fn).call(:external_fn).using(external)
      before(:some_fn).call(:other_local_fn)
    end

    hooks2 = CptHook::define_hooks do
      before(:some_fn).call(:local_fn)
    end

    wrapped = CptHook::Hookable.new(@obj_to_wrap, hooks.merge(hooks2))
    expect(external).to receive(:external_fn)
    expect(@obj_to_wrap).to receive(:local_fn)
    wrapped.some_fn
  end
end
