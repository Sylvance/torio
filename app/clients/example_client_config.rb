# frozen_string_literal: true

# ExampleClientConfig
class ExampleClientConfig < ApplicationClient::Config
  attributes Parameter.new(:api_key, String),
             Parameter.new(:endpoint_url, String),
             Parameter.new(:timeout, Integer)

  validates :api_key, presence: true
  validates :endpoint_url, presence: true, format: URI::regexp(%w[http https])
  validates :timeout, numericality: { only_integer: true, greater_than: 0 }
end
