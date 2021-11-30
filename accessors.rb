module Accessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attr_accessor_with_history(*methods)
      methods.each do |method|
        define_method(method) { instance_variable_get("@#{method}") }

        define_method("#{method}=") do |value|
          instance_variable_set("@#{method}", value)
          self.send("#{method}_history") << value
        end

        define_method("#{method}_history") do
          instance_variable_get("@#{method}_history") ||
            instance_variable_set("@#{method}_history", [])
        end
      end
    end

    def strong_attr_accessor(attribute_name, attribute_class)
      define_method(attribute_name) { instance_variable_get("@#{attribute_name}") }

      define_method("#{attribute_name}=") do |value|
        if value.instance_of?(attribute_class)
          instance_variable_set("@#{attribute_name}", value)
        else
          raise "The type is different from what is required: #{attribute_class}."
        end
      end
    end
  end
end
