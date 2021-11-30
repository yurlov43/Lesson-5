module Validation
  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
    base.class_variable_set(:@@attributes, {})
    base.instance_variable_set(:@errors, [])
  end

  module InstanceMethods
    def validate!
      self.class.errors = nil
      self.class.attributes.each do |attribute_name, methods|
        methods.each { |validation_type, parameter| self.class.send(validation_type, attribute_name, parameter) }
      end
      raise self.class.errors.join("\n") unless self.class.errors.empty?
    rescue RuntimeError => error
      puts error.message
      raise error
    end

    def valid?
      validate!
      true
    rescue RuntimeError
      false
    end
  end

  module ClassMethods
    def attributes
      self.class_variable_get(:@@attributes)
    end

    def errors
      @errors
    end

    def errors=(value)
      value.nil? ? @errors = [] : @errors << value
    end

    define_method(:presence) do |attribute_name, parameter|
      if attribute_name.nil? || attribute_name == ''
        self.errors = "Attribute name not specified."
      end
    end

    define_method(:format) do |attribute_name, parameter|
      unless !parameter.nil? && attribute_name.to_s =~ parameter
        self.errors = "Invalid attribute value."
      end
    end

    define_method(:type) do |attribute_name, parameter|
      unless !parameter.nil? && attribute_name.instance_of?(parameter)
        self.errors = "The attribute value does not match the specified class."
      end
    end

    def validate(attribute_name, validation_type, *parameter)
      self.attributes[attribute_name] ||= {}
      self.attributes[attribute_name][validation_type] = parameter.first
    end
  end
end