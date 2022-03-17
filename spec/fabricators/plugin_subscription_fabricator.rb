# frozen_string_literal: true

Fabricator(:plugin_subscription) do
  product_id = SecureRandom.hex(8)
  price_id = SecureRandom.hex(8)
  supplier_name { "pavilion" }
  product_id { product_id }
  product_name { "Plugin Subscription" }
  product_name_slug { "plugin-subscription" }
  price_id { price_id }
  unique_id { product_id + price_id }
  price_nickname { "Business" }
  price_nickname_slug { "business" }
  active  { true }
  created_at { Time.zone.now }
  updated_at { Time.zone.now }
end
