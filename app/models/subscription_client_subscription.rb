# frozen_string_literal: true

class SubscriptionClientSubscription < ActiveRecord::Base
  validates :product_id, presence: true, uniqueness: { scope: :price_id }
  validates :price_id, presence: true

  belongs_to :resource, class_name: "SubscriptionClientResource"
  delegate :name, to: :resource, prefix: true

  def active?
    self.active && updated_at.to_datetime > (Time.zone.now - 2.hours).to_datetime
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
#  active       :boolean          default(FALSE), not null
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
