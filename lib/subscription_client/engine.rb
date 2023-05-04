# frozen_string_literal: true

module ::SubscriptionClient
  PLUGIN_NAME ||= 'subscription_client'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace SubscriptionClient
  end

  class << self
    def root
      Rails.root
    end

    def plugin_status_server_url
      "https://discourse.pluginmanager.org"
    end

    def database_exists?
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
    end

    def find_subscriptions(resource_name = nil)
      return nil unless resource_name

      subscriptions = SubscriptionClientSubscription.active
        .includes(resource: [:supplier])
        .references(resource: [:supplier])
        .where("subscription_client_resources.name = ? ", resource_name)

      result = SubscriptionClient::Subscriptions::Result.new
      return result unless subscriptions.exists?

      result.resource = subscriptions.first.resource
      result.supplier = subscriptions.first.resource.supplier
      result.subscriptions = subscriptions.to_a

      result
    end
  end
end
