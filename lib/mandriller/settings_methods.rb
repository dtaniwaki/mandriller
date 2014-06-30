module Mandriller
  module SettingsMethods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def define_settings_methods(*keys)
        options = keys[-1].is_a?(Hash) ? keys.pop : {}
        if default = options[:default]
          arg_s = "v = #{default.inspect}"
        else
          arg_s = "v"
        end

        getter = options[:getter]

        keys.flatten.each do |key|
          class_eval <<-EOS
          class_attribute :mandrill_#{key}
          def self.set_mandrill_setting_#{key}(#{arg_s})
            self.mandrill_#{key} = v
          end
          private_class_method :set_mandrill_setting_#{key}
          self.singleton_class.send :alias_method, :set_#{key}, :set_mandrill_setting_#{key}
          def set_mandrill_setting_#{key}(#{arg_s})
            @mandrill_#{key} = v
          end
          private :set_mandrill_setting_#{key}
          alias_method :set_#{key}, :set_mandrill_setting_#{key}
          EOS

          method_name = "get_mandrill_setting_#{key}"
          define_method method_name do
            v = get_mandrill_setting_value(key)
            if getter
              getter.call(v)
            else
              v
            end
          end
          private method_name
        end
      end
    end

    def get_mandrill_setting_value(key)
      instance_variable_defined?("@mandrill_#{key}") ? instance_variable_get("@mandrill_#{key}") : __send__("mandrill_#{key}")
    end
    private :get_mandrill_setting_value

    def is_mandrill_setting_defined?(key)
      v = get_mandrill_setting_value(key)
      !v.nil?
    end
    private :is_mandrill_setting_defined?

    def get_mandrill_setting(key)
      __send__ "get_mandrill_setting_#{key}"
    end
    private :get_mandrill_setting
  end
end
