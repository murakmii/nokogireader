require 'rspec/its'
require 'simplecov'

SimpleCov.start do
  add_filter 'vendor'
  add_filter '.bundle'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nokogireader'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
