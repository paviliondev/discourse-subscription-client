# spec_helper.rb

require "rspec"


pp "hi!"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
