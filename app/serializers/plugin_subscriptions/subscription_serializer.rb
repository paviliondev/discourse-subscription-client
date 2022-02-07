# frozen_string_literal: true
class PluginSubscriptions::SubscriptionSerializer < ApplicationSerializer
  attributes :unique_id,
             :supplier_name,
             :product_name_slug,
             :product_name,
             :price_nickname,
             :price_nickname_slug,
             :active
end
