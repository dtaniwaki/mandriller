require 'rubygems'
require 'coveralls'
Coveralls.wear!

require 'mandriller'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.before :suite do
    ActionMailer::Base.delivery_method = :test
  end
end

