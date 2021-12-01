module Validation
  def self.included(base)
    base.include InstanceMethods
    base.extend ClassMethods
    base.class_variable_set(:@@attributes, {})
  end

  module InstanceMethods
    def validate!
      self.errors = nil
      self.class.attributes.each do |attribute_name, methods|
        methods.each { |validation_type, parameter| self.send(validation_type, attribute_name, parameter) }
      end
      unless errors.empty?
        puts errors
        raise errors.join("\n") unless errors.empty?
      end
    end

    def valid?
      validate!
      true
    rescue RuntimeError
      false
    end

    protected

    def errors
      @errors
    end

    def errors=(value)
      @errors.nil? || value.nil? ? @errors = [] : @errors << value
    end

    define_method(:presence) do |attribute_name, parameter|
      if attribute_name.nil? || attribute_name == ''
        self.errors = "#{attribute_name}: attribute name not specified."
      end
    end

    define_method(:format) do |attribute_name, parameter|
      unless !parameter.nil? && attribute_name.to_s =~ parameter
        self.errors = "#{attribute_name}: invalid attribute value."
      end
    end

    define_method(:type) do |attribute_name, parameter|
      unless !parameter.nil? && attribute_name.instance_of?(parameter)
        self.errors = "#{attribute_name}: the attribute value does not match the specified class."
      end
    end
  end

  module ClassMethods
    def validate(attribute_name, validation_type, *parameter)
      self.attributes[attribute_name] ||= {}
      self.attributes[attribute_name][validation_type] = parameter.first
    end

    def attributes
      self.class_variable_get(:@@attributes)
    end
  end
end