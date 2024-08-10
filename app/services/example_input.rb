# frozen_string_literal: true

# ExampleInput
class ExampleInput < ApplicationService::Input
  attributes Parameter.new(:name, String), Parameter.new(:age, Integer)

  validates :name, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :valid_age?

  def valid_age?
    return if age >= 18

    errors.add(:age, 'must be for an adult')
  end
end
