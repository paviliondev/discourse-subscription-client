# frozen_string_literal: true

class SubscriptionClientSupplierSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :authorized,
             :authorized_at

  has_one :user, serializer: BasicUserSerializer

  def authorized
    object.api_key.present? && object.authorized_at.present?
  end
end
