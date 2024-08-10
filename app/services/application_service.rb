# frozen_string_literal: true

# ApplicationService
module ApplicationService
  attr_accessor :parameters

  def initialize(parameters: self.class.input_definition.null)
    unless parameters.is_a?(Input)
      raise NotImplementedError, 'parameters must be an ApplicationService::Input'
    end

    if parameters.valid_params.is_a?(Result) && parameters.valid_params.success?
      @parameters = parameters
    else
      @parameters = parameters.valid_params
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def input_definition
      raise NotImplementedError, 'input_definition must be defined in the subclass'
    end
  end

  def execute
    if parameters.is_a?(Result) && parameters.failure?
      return parameters
    end

    Result.try { perform }
  end

  private def perform
    raise NotImplementedError, 'perform must be implemented in the subclass'
  end

  class Result
    attr_reader :value, :error, :error_type

    def initialize(value: nil, error: nil, error_type: nil)
      @value = value
      @error = error
      @error_type = error_type
    end

    def success?
      false
    end

    def failure?
      false
    end

    def self.success(value)
      Success.new(value:)
    end

    def self.failure(error, error_type = :unexpected)
      Failure.new(error:, error_type:)
    end

    def transform
      return self if failure?

      self.class.success(yield(value))
    end

    def self.try
      success(yield)
    rescue StandardError => e
      failure(e.message, e.class.name.underscore.to_sym)
    end

    def and_then
      return self if failure?

      yield(value)
    end

    def value!
      if success?
        value
      else
        raise "Called value! on a Failure: #{error}"
      end
    end
  end

  class Success < Result
    def success?
      true
    end

    def deconstruct_keys(_keys)
      { success: true, value: }
    end
  end

  class Failure < Result
    def failure?
      true
    end

    def deconstruct_keys(_keys)
      { failure: true, error:, error_type: }
    end
  end

  class Input
    include ActiveModel::Validations
    include ActiveModel::Model

    Parameter = Struct.new(:name, :type)

    attr_reader :params

    def initialize(params = {})
      @params = params
      @attributes = self.class.instance_variable_get(:@attributes) || []
      assign_attributes
    end

    def self.attributes(*attributes)
      @attributes ||= []
      @attributes += attributes
      attributes.each do |attribute|
        attr_accessor attribute.name
        define_attribute_method(attribute)
      end
    end

    def self.define_attribute_method(attribute)
      define_method(attribute.name) do
        @params[attribute.name] || @params[attribute.name.to_s]
      end

      define_method("#{attribute.name}=") do |value|
        @params[attribute.name] = cast_value(attribute.type, value)
      end
    end

    def self.null
      NullInput.new
    end

    def valid_params
      return Result.failure(errors.full_messages.join(', '), :invalid_input) unless valid?

      Result.success(@params)
    end

    private

    def assign_attributes
      @attributes.each do |attribute|
        value = @params[attribute.name] || @params[attribute.name.to_s]
        send("#{attribute.name}=", value)
      end
    end

    def cast_value(type, value)
      return value if value.is_a?(type)

      case type.to_s
      when 'Integer'
        value.to_i
      when 'Float'
        value.to_f
      when 'String'
        value.to_s
      when 'Boolean'
        ActiveModel::Type::Boolean.new.cast(value)
      when 'Date'
        Date.parse(value) rescue value
      when 'Time'
        Time.parse(value) rescue value
      when 'DateTime'
        DateTime.parse(value) rescue value
      when 'Hash'
        value.is_a?(Hash) ? value : {}
      when 'Array'
        value.is_a?(Array) ? value : []
      else
        value
      end
    end
  end

  class NullInput < Input
    def initialize
      super({})
    end

    def valid_params
      Result.success({})
    end

    def method_missing(name, *args, &block)
      nil
    end

    def respond_to_missing?(name, include_private = false)
      true
    end
  end
end
