# frozen_string_literal: true

class SubscriptionClientSupplierSerializer < ApplicationSerializer
  attributes :name,
             :user_id,
             :authorized_at
end
