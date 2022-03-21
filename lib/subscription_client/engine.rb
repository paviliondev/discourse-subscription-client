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
      "https://plugins.discourse.pavilion.tech"
    end
  end
end
