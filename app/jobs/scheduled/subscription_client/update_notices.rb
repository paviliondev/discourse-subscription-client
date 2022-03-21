# frozen_string_literal: true

class Jobs::SubscriptionClientUpdateNotices < ::Jobs::Scheduled
  every 5.minutes

  def execute(args = {})
    SubscriptionClient::Notices.update
  end
end
