# frozen_string_literal: true

module AdminPluginsControllerExtension

  def index
    plugins = Discourse.visible_plugins

    if !guardian.can_manage_subscriptions?
      plugins = plugins.select { |p| p.name != "discourse-subscription-client" }
    end

    render_serialized(plugins, AdminPluginSerializer, root: 'plugins')
  end

end
