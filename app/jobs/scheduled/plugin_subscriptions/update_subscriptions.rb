# frozen_string_literal: true

class Jobs::PluginSubscriptionsUpdateSubscriptions < ::Jobs::Scheduled
  every 1.hour

  def execute(args = {})
    PluginSubscriptions::Subscriptions.update
  end
end
