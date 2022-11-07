# frozen_string_literal: true

class Jobs::SubscriptionClientFindResources < ::Jobs::Base
  def execute(args = {})
    SubscriptionClient::Resources.find_all unless Rails.env.test?
  end
end
