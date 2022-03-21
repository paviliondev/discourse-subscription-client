# frozen_string_literal: true

class Jobs::SubscriptionClientUpdateSubscriptions < ::Jobs::Scheduled
  every 1.day

  def execute(args = {})
    SubscriptionClient::Subscriptions.update
  end
end
