# frozen_string_literal: true

# ApplicationClient
module ApplicationClient
  attr_accessor :config

  def initialize(config: self.class.config_definition.null)
    unless config.is_a?(Config)
      raise NotImplementedError, 'config must be an ApplicationClient::Config'
    end

    if config.valid_config.is_a?(Result) && config.valid_config.success?
      @config = config
    else
      @config = config.valid_config
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def config_definition
      raise NotImplementedError, 'config_definition must be defined in the subclass'
    end

    def result_codes
      raise NotImplementedError, 'result_codes must be defined in the subclass'
    end

    def failure_codes
      raise NotImplementedError, 'failure_codes must be defined in the subclass'
    end
  end

  def execute_request
    if config.is_a?(Result) && config.failure?
      return config
    end

    Result.try { perform_request }
          .transform { |result| translate_result_code(result) }
          .and_then { |result| validate_response(result) }
          .rescue_failure { |failure| translate_failure_code(failure) }
  end

  private

  def perform_request
    raise NotImplementedError, 'perform_request must be implemented in the subclass'
  end

  def translate_result_code(result)
    self.class.result_codes.fetch(result, :unknown_result)
  end

  def validate_response(result)
    if result == :unknown_result
      Result.failure('Unknown result code', :unknown_result_code)
    else
      Result.success(result)
    end
  end

  def translate_failure_code(failure)
    translated_error = self.class.failure_codes.fetch(failure.error_type, :unknown_failure)
    Result.failure(failure.error, translated_error)
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

    def rescue_failure
      return self unless failure?

      yield(self)
    end
  end

  class Success < Result
    def success?
      true
    end
  end

  class Failure < Result
    def failure?
      true
    end
  end

  class Config
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
      NullConfig.new
    end

    def valid_config
      validate_nested_configs!
      return Result.failure(errors.full_messages.join(', '), :invalid_config) unless valid?

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
      when 'Config'
        value.is_a?(Config) ? value : type.new(value)
      else
        value
      end
    end

    def validate_nested_configs!
      @attributes.each do |attribute|
        nested_config = send(attribute.name)
        next unless nested_config.is_a?(Config)

        nested_config_valid_result = nested_config.valid_config
        if nested_config_valid_result.failure?
          errors.add(attribute.name, "is invalid: #{nested_config_valid_result.error}")
        end
      end
    end
  end

  class NullConfig < Config
    def initialize
      super({})
    end

    def valid_config
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
