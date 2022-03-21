# frozen_string_literal: true

require_relative '../plugin_helper'

describe SubscriptionClientSubscriptionSerializer do
  fab!(:subscription_client_subscription) { Fabricate(:subscription_client_subscription) }

  it 'should return subscription attributes' do
    serialized_json = described_class.new(subscription_client_subscription, root: false).to_json

    [:supplier_name, :product_name, :price_name, :active, :updated_at].each do |key|
      expect(serialized_json[supplier_name.to_s]).to eq(subscription_client_subscription.send(key))
    end
  end
end
