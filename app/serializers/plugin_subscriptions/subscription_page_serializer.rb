# frozen_string_literal: true
class PluginSubscriptions::SubscriptionPageSerializer < ApplicationSerializer
  attributes :server, :updated_at

  has_one :authentication, serializer: PluginSubscriptions::AuthenticationSerializer, embed: :objects
  has_many :subscriptions, serializer: PluginSubscriptions::SubscriptionSerializer, embed: :objects

  def updated_at
    Time.now
  end
end
