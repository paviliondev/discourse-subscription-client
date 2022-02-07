# frozen_string_literal: true

class Jobs::PluginSubscrioptionsUpdateNotices < ::Jobs::Scheduled
  every 5.minutes

  def execute(args = {})
    PluginSubscriptions::Notice.update
  end
end
