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

        keys.flatten.each do |key|
          class_eval <<-EOS
          class_attribute :mandrill_#{key}
          def self.set_#{key}(#{arg_s})
            self.mandrill_#{key} = v
          end
          private_class_method :set_#{key}
          def set_#{key}(#{arg_s})
            @mandrill_#{key} = v
          end
          private :set_#{key}
          EOS
        end
      end
    end

    def get_mandrill_setting(key)
      instance_variable_defined?("@mandrill_#{key}") ? instance_variable_get("@mandrill_#{key}") : __send__("mandrill_#{key}")
    end
    private :get_mandrill_setting
  end
end
