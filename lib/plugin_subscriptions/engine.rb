# frozen_string_literal: true

module ::PluginSubscriptions
  PLUGIN_NAME ||= 'plugin_subscriptions'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace PluginSubscriptions
  end
end
