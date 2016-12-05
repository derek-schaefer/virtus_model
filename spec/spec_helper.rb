require 'simplecov'
SimpleCov.start

require 'bundler/setup'
Bundler.setup

require 'virtus_model'
require 'shoulda/matchers'
require 'shoulda/callback/matchers'
require 'active_support/core_ext/object/try'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end
