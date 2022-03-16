# frozen_string_literal: true
# name: discourse-plugin-subscriptions
# about: Plugin subscription client
# version: 0.0.1
# authors: Robert Barrow, Angus McLeod
# url: https://github.com/paviliondev/discourse-plugin-subscriptions.git

register_asset 'stylesheets/admin/admin.scss', :desktop
register_asset 'stylesheets/admin/variables.scss', :desktop

enabled_site_setting :plugin_subscriptions_enabled
add_admin_route "admin.plugin_subscriptions.title", "plugin-subscriptions"

after_initialize do

  %w[
    ../lib/plugin_subscriptions/engine.rb
    ../config/routes.rb
    ../lib/plugin_subscriptions/notice.rb
    ../lib/plugin_subscriptions/notice/connection_error.rb
    ../lib/plugin_subscriptions/subscriptions.rb
    ../lib/plugin_subscriptions/subscriptions_retrieve_results.rb
    ../lib/plugin_subscriptions/subscriptions/authentication.rb
    ../app/models/plugin_subscriptions/plugin_subscription.rb
    ../app/controllers/plugin_subscriptions/admin/admin.rb
    ../app/controllers/plugin_subscriptions/admin/subscriptions.rb
    ../app/controllers/plugin_subscriptions/admin/notice.rb
    ../app/jobs/scheduled/plugin_subscriptions/update_subscriptions.rb
    ../app/jobs/scheduled/plugin_subscriptions/update_notices.rb
    ../app/serializers/plugin_subscriptions/authentication_serializer.rb
    ../app/serializers/plugin_subscriptions/subscription_serializer.rb
    ../app/serializers/plugin_subscriptions/subscription_page_serializer.rb
    ../app/serializers/plugin_subscriptions/notice_serializer.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end

  Discourse::Application.routes.append do
    mount ::PluginSubscriptions::Engine, at: '/plugin-subs'
  end

  AdminDashboardData.add_problem_check do
    warning_notices = PluginSubscriptions::Notice.list(
      type: PluginSubscriptions::Notice.types[:warning],
      archetype: PluginSubscriptions::Notice.archetypes[:plugin_status]
    )
    warning_notices.any? ? ActionView::Base.full_sanitizer.sanitize(warning_notices.first.message, tags: %w(a)) : nil
  end

  DiscourseEvent.trigger(:plugin_subscriptions_ready)
end
