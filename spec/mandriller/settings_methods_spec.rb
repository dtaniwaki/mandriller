require 'spec_helper'

describe Mandriller::SettingsMethods do
  let(:klass) do
    Class.new do
      include Mandriller::SettingsMethods
    end
  end
  subject do
    klass.class_eval do
      define_settings_methods :foo
    end
    klass
  end

  it "defines the methods" do
    expect(subject.private_methods).to include(:set_foo)
    expect(subject).to respond_to(:mandrill_foo)
    expect(subject.private_instance_methods).to include(:set_foo)

    instance = subject.new
    expect(instance.instance_variable_defined?("@mandrill_foo")).to eq(false)
  end
  it "sets the instance variable" do
    instance = subject.new
    instance.send :set_foo, 'foo'
    expect(instance.instance_variable_get("@mandrill_foo")).to eq('foo')
  end
  it "sets the class attribute" do
    subject.send :set_foo, 'foo'
    expect(subject.mandrill_foo).to eq('foo')
  end

  context "with default option" do
    subject do
      klass.class_eval do
        define_settings_methods :foo, default: 'bar'
      end
      klass
    end
    it "sets the instance variable with default value" do
      instance = subject.new
      instance.send :set_foo
      expect(instance.instance_variable_get("@mandrill_foo")).to eq('bar')
    end
    it "sets the class attribute with default value" do
      subject.send :set_foo
      expect(subject.mandrill_foo).to eq('bar')
    end
  end

  describe "#get_mandrill_setting" do
    it "returns class_attribute" do
      subject.send :set_foo, 1
      instance = subject.new
      expect(instance.send(:get_mandrill_setting, :foo)).to eq(1)
    end
    it "returns instance_variable" do
      instance = subject.new
      instance.send :set_foo, 2
      expect(instance.send(:get_mandrill_setting, :foo)).to eq(2)
    end
    it "returns instance_variable over class_attribute" do
      subject.send :set_foo, 1
      instance = subject.new
      instance.send :set_foo, 2
      expect(instance.send(:get_mandrill_setting, :foo)).to eq(2)
    end
  end
end
