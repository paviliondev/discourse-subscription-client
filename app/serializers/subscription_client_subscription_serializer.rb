# frozen_string_literal: true

class SubscriptionClientSubscriptionSerializer < ApplicationSerializer
  attributes :resource_name,
             :product_name,
             :price_name,
             :active,
             :updated_at
end
