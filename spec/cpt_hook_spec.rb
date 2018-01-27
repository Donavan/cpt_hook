RSpec.describe CptHook do
  it "has a version number" do
    expect(CptHook::VERSION).not_to be nil
  end

  it "has a method to define hooks" do
    expect(CptHook).to respond_to(:define_hooks)
  end
end
