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
          class_attribute "mandrill_#{key}"

          method_name = "set_mandrill_setting_#{key}"
          singleton_class.class_eval <<-EOS
          def #{method_name}(#{arg_s})
            self.mandrill_#{key} = v
          end
          private :#{method_name}
          alias_method :set_#{key}, :#{method_name}
          EOS

          class_eval <<-EOS
          def #{method_name}(#{arg_s})
            @mandrill_#{key} = v
          end
          private :#{method_name}
          alias_method :set_#{key}, :#{method_name}
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
      !get_mandrill_setting_value(key).nil?
    end
    private :is_mandrill_setting_defined?

    def get_mandrill_setting(key)
      __send__ "get_mandrill_setting_#{key}"
    end
    private :get_mandrill_setting
  end
end
