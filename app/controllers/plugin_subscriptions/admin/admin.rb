# frozen_string_literal: true
class PluginSubscriptions::AdminController < ::Admin::AdminController
  before_action :ensure_admin

  def index
    render_json_dump(
      #TODO replace with appropriate static?
      #api_section: ["business"].include?(TopicPreviews::Subscription.type),
      active_notice_count: PluginSubscriptions::Notice.active_count,
      featured_notices: ActiveModel::ArraySerializer.new(
        PluginSubscriptions::Notice.list(
          type: PluginSubscriptions::Notice.types[:info],
          archetype: PluginSubscriptions::Notice.archetypes[:subscription_message]
        ),
        each_serializer: PluginSubscriptions::NoticeSerializer
      )
    )
  end
end
