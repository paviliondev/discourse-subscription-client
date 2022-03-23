# frozen_string_literal: true

class SubscriptionClientSupplierSerializer < ApplicationSerializer
  attributes :name,
             :authorized_at

  has_one :user, serializer: BasicUserSerializer
end
