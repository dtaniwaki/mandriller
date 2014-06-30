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

  describe "::define_settings_methods" do
    it "defines the methods" do
      expect(subject.private_methods).to include(:set_mandrill_setting_foo)
      expect(subject.private_methods).to include(:set_foo)
      expect(subject).to respond_to(:mandrill_foo)
      expect(subject.private_instance_methods).to include(:set_mandrill_setting_foo)
      expect(subject.private_instance_methods).to include(:set_foo)
      expect(subject.private_instance_methods).to include(:get_mandrill_setting_foo)

      instance = subject.new
      expect(instance.instance_variable_defined?("@mandrill_foo")).to eq(false)
    end

    it "sets the instance variable" do
      instance = subject.new
      instance.send :set_mandrill_setting_foo, 'foo'
      expect(instance.instance_variable_get("@mandrill_foo")).to eq('foo')
    end
    it "sets the class attribute" do
      subject.send :set_mandrill_setting_foo, 'foo'
      expect(subject.mandrill_foo).to eq('foo')
    end
    it "gets the value as is" do
      instance = subject.new
      instance.send :set_mandrill_setting_foo, 'foo'
      expect(instance.send(:get_mandrill_setting_foo)).to eq('foo')
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
        instance.send :set_mandrill_setting_foo
        expect(instance.instance_variable_get("@mandrill_foo")).to eq('bar')
      end
      it "sets the class attribute with default value" do
        subject.send :set_mandrill_setting_foo
        expect(subject.mandrill_foo).to eq('bar')
      end
    end

    context "with getter option" do
      subject do
        klass.class_eval do
          define_settings_methods :foo, getter: lambda { |v| v.to_sym }
        end
        klass
      end
      it "gets the value as is" do
        instance = subject.new
        instance.send :set_mandrill_setting_foo, 'foo'
        expect(instance.send(:get_mandrill_setting_foo)).to eq(:foo)
      end
    end
  end

  describe "#get_mandrill_setting_value" do
    it "returns the value set globally" do
      subject.send :set_mandrill_setting_foo, 1
      instance = subject.new
      expect(instance.send(:get_mandrill_setting_value, :foo)).to eq(1)
    end
    it "returns the value set locally" do
      instance = subject.new
      instance.send :set_mandrill_setting_foo, 2
      expect(instance.send(:get_mandrill_setting_value, :foo)).to eq(2)
    end
    it "returns the value set locally over the one set globally" do
      subject.send :set_mandrill_setting_foo, 1
      instance = subject.new
      instance.send :set_mandrill_setting_foo, 2
      expect(instance.send(:get_mandrill_setting_value, :foo)).to eq(2)
    end
  end

  describe "#is_mandrill_setting_defined?" do
    it "returns true for the value set globally" do
      subject.send :set_mandrill_setting_foo, 1
      instance = subject.new
      expect(instance.send(:is_mandrill_setting_defined?, :foo)).to eq(true)
    end
    it "returns true for the value set localy" do
      instance = subject.new
      instance.send :set_mandrill_setting_foo, 2
      expect(instance.send(:is_mandrill_setting_defined?, :foo)).to eq(true)
    end
    it "returns false for non set value" do
      instance = subject.new
      expect(instance.send(:is_mandrill_setting_defined?, :foo)).to eq(false)
    end
  end

  describe "#get_mandrill_setting" do
    it "delegates to the setting method" do
      instance = subject.new
      ret = double
      expect(instance).to receive(:get_mandrill_setting_foo).and_return(ret)
      expect(instance.send(:get_mandrill_setting, :foo)).to eq(ret)
    end
  end
end
