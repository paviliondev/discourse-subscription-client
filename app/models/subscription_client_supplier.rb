# frozen_string_literal: true

class SubscriptionClientSupplier < ActiveRecord::Base
  has_many :resources, foreign_key: "resource_id", class_name: "SubscriptionClientResource"
  has_many :notices, class_name: "SubscriptionClientNotice", as: :notice_subject, dependent: :destroy

  scope :with_keys, -> { where("api_key IS NOT NULL") }

  def destroy_authorization
    update(api_key: nil, user_id: nil, authorized_at: nil)
  end

  def authorized?
    api_key.present?
  end
end

# == Schema Information
#
# Table name: subscription_client_suppliers
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  url           :string           not null
#  api_key       :string
#  user_id       :datetime
#  authorized_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_subscription_client_suppliers_on_url  (url) UNIQUE
#
