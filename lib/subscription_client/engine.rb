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

      resource = subscriptions.first.resource
      supplier = resource.supplier
      products = supplier.product_slugs(resource_name)
      return result unless products.present?

      result.resource = resource
      result.supplier = supplier
      result.subscriptions = subscriptions.to_a
      result.products = products

      result
    end
  end
end
