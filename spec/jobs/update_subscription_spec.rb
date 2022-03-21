# frozen_string_literal: true

require_relative '../plugin_helper'

describe Jobs::SubscriptionClientUpdateSubscriptions do
  it "updates the subscription" do
    stub_subscription_request(200, valid_subscription)
    described_class.new.execute
    expect(SubscriptionClientSubscription.exists?(product_id: valid_subscription[:product_id])).to eq(true)
  end
end
