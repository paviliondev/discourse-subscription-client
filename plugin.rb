# frozen_string_literal: true
# name: discourse-subscription-client
# about: Subscription Client for Plugin Subscriptions
# version: 0.2.3
# authors: Robert Barrow, Angus McLeod
# url: https://github.com/paviliondev/discourse-subscription-client.git
# contact_emails: development@pavilion.tech

register_asset 'stylesheets/common/common.scss'
enabled_site_setting :subscription_client_enabled
add_admin_route "admin.subscription_client.title", "subscriptionClient"
register_svg_icon "far-building"

load File.expand_path("../lib/validators/allow_moderator_supplier_management.rb", __FILE__)

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
    ../lib/subscription_client/subscriptions/update_result.rb
    ../app/models/subscription_client_notice.rb
    ../app/models/subscription_client_resource.rb
    ../app/models/subscription_client_subscription.rb
    ../app/models/subscription_client_supplier.rb
    ../app/controllers/subscription_client/admin_controller.rb
    ../app/controllers/subscription_client/subscriptions_controller.rb
    ../app/controllers/subscription_client/suppliers_controller.rb
    ../app/controllers/subscription_client/notices_controller.rb
    ../app/controllers/subscription_client/no_access_controller.rb
    ../app/serializers/subscription_client_supplier_serializer.rb
    ../app/serializers/subscription_client_resource_serializer.rb
    ../app/serializers/subscription_client_notice_serializer.rb
    ../app/serializers/subscription_client_subscription_serializer.rb
    ../app/jobs/regular/subscription_client/find_resources.rb
    ../app/jobs/scheduled/subscription_client/update_subscriptions.rb
    ../app/jobs/scheduled/subscription_client/update_notices.rb
    ../extensions/admin_plugins_controller.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end

  if SubscriptionClient.database_exists? && !Rails.env.test?
    Jobs.enqueue(:subscription_client_find_resources)
  end

  add_to_class(:guardian, :can_manage_subscriptions?) do
    return false unless SiteSetting.subscription_client_enabled

    is_admin? || (
      is_staff? &&
      SiteSetting.subscription_client_allow_moderator_subscription_management
    )
  end

  add_to_class(:guardian, :can_manage_suppliers?) do
    return false unless SiteSetting.subscription_client_enabled && can_manage_subscriptions?

    is_admin? || (
      is_staff? &&
      SiteSetting.subscription_client_allow_moderator_supplier_management
    )
  end

  User.has_many(:subscription_client_suppliers)
  add_to_serializer(:current_user, :subscription_notice_count) do
    SubscriptionClientNotice.list(visible: true).count
  end
  add_to_serializer(:current_user, :include_subscription_notice_count) do
    scope.can_manage_subscriptions?
  end
  add_to_serializer(:current_user, :can_manage_subscriptions) do
    scope.can_manage_subscriptions?
  end
  add_to_serializer(:current_user, :can_manage_suppliers) do
    scope.can_manage_suppliers?
  end

  AdminDashboardData.add_scheduled_problem_check(:subscription_client) do
    return unless SiteSetting.subscription_client_warning_notices_on_dashboard

    notices = SubscriptionClientNotice.list(
      notice_type: SubscriptionClientNotice.error_types,
      visible: true
    )
    notices.map do |notice|
      AdminDashboardData::Problem.new(
        "#{notice.title}: #{notice.message}",
        priority: "high",
        identifier: "subscription_client_notice_#{notice.id}"
      )
    end
  end

  Admin::PluginsController.prepend AdminPluginsControllerExtension

  DiscourseEvent.trigger(:subscription_client_ready)
end
