module Mandriller
  module SettingsMethods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def define_settings_methods(*keys)
        options = keys[-1].is_a?(Hash) ? keys.pop : {}

        keys.flatten.each do |key|
          class_attribute "mandrill_#{key}"

          define_mandrill_setter(key, options)
          define_mandrill_getter(key, options)
        end
      end

      private

      def define_mandrill_setter(key, options = {})
        if default = options[:default]
          arg_s = "v = #{default.inspect}"
        else
          arg_s = "v"
        end

        method_name = "set_mandrill_setting_#{key}"
        [self, singleton_class].each do |base|
          base.class_eval <<-EOS
          def #{method_name}(#{arg_s})
            self.mandrill_#{key} = v
          end
          private :#{method_name}
          alias_method :set_#{key}, :#{method_name}
          EOS
        end
      end

      def define_mandrill_getter(key, options = {})
        getter = options[:getter]

        method_name = "get_mandrill_setting_#{key}"
        define_method method_name do
          v = __send__("mandrill_#{key}")
          if getter
            getter.call(v)
          else
            v
          end
        end
        private method_name
      end
    end

    def is_mandrill_setting_defined?(key)
      !__send__("mandrill_#{key}").nil?
    end
    private :is_mandrill_setting_defined?

    def get_mandrill_setting(key)
      __send__ "get_mandrill_setting_#{key}"
    end
    private :get_mandrill_setting
  end
end
