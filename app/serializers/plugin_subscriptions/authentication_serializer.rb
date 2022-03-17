# frozen_string_literal: true

class PluginSubscriptions::AuthenticationSerializer < ApplicationSerializer
  attributes :active,
             :client_id,
             :auth_by,
             :auth_at

  def active
    object.active?
  end
end
