# frozen_string_literal: true
# name: discourse-subscription-client
# about: Subscription client
# version: 0.1.0
# authors: Robert Barrow, Angus McLeod
# url: https://github.com/paviliondev/discourse-subscription-client.git

register_asset 'stylesheets/common/common.scss'
enabled_site_setting :subscription_client_enabled
add_admin_route "admin.subscription_client.title", "subscriptionClient"

after_initialize do
  %w[
    ../lib/subscription_client/engine.rb
    ../config/routes.rb
    ../lib/subscription_client/request.rb
    ../lib/subscription_client/authorization.rb
    ../lib/subscription_client/resources.rb
    ../lib/subscription_client/notices.rb
    ../lib/subscription_client/subscriptions.rb
    ../lib/subscription_client/subscriptions/result.rb
    ../app/models/subscription_client_notice.rb
    ../app/models/subscription_client_resource.rb
    ../app/models/subscription_client_subscription.rb
    ../app/models/subscription_client_supplier.rb
    ../app/controllers/subscription_client/admin_controller.rb
    ../app/controllers/subscription_client/subscriptions_controller.rb
    ../app/controllers/subscription_client/authorization_controller.rb
    ../app/controllers/subscription_client/notices_controller.rb
    ../app/jobs/scheduled/subscription_client/update_subscriptions.rb
    ../app/jobs/scheduled/subscription_client/update_notices.rb
    ../app/serializers/subscription_client_notice_serializer.rb
    ../app/serializers/subscription_client_subscription_serializer.rb
    ../app/serializers/subscription_client_supplier_serializer.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end

  AdminDashboardData.add_problem_check do
    warnings = SubscriptionClientNotice.list_warnings
    warnings.any? ? ActionView::Base.full_sanitizer.sanitize(warnings.first.message, tags: %w(a)) : nil
  end

  SubscriptionClient::Resources.find_all unless Rails.env.test?

  DiscourseEvent.trigger(:subscription_client_ready)
end
