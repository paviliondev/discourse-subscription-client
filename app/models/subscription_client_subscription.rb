# frozen_string_literal: true

class SubscriptionClientSubscription < ActiveRecord::Base
  validates :product_id, presence: true, uniqueness: { scope: :price_id }
  validates :price_id, presence: true

  belongs_to :resource, class_name: "SubscriptionClientResource"

  scope :active, lambda {
    where(
      "subscription_client_subscriptions.subscribed = true AND
       subscription_client_subscriptions.updated_at > ?", SubscriptionClientSubscription.update_period
    )
  }

  def active
    self.subscribed && updated_at.to_datetime > self.class.update_period.to_datetime
  end

  def activate!
    self.update(subscribed: true)
  end

  def deactivate!
    self.update(subscribed: false)
  end

  def resource_name
    resource.name
  end

  def supplier_name
    resource.supplier.name
  end

  def self.update_period
    Time.zone.now - 2.days
  end
end

# == Schema Information
#
# Table name: subscription_client_subscriptions
#
#  id           :bigint           not null, primary key
#  resource_id  :bigint
#  product_id   :string           not null
#  product_name :string
#  price_id     :string           not null
#  price_name   :string
#  subscribed   :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_subscription_client_subscriptions_on_resource_id  (resource_id)
#  sc_unique_subscriptions                                 (resource_id,product_id,price_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (resource_id => subscription_client_resources.id)
#
