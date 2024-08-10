# frozen_string_literal: true

# ExampleService
class ExampleService
  include ApplicationService

  def self.input_definition
    ExampleInput
  end

  private

  def perform
    Rails.logger.info "Executing with: #{parameters.name}, #{parameters.age}"
    Result.success('Executed successfully')
  end
end
