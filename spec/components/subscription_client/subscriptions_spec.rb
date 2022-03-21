# frozen_string_literal: true

require_relative '../../plugin_helper'

describe SubscriptionClient::Subscriptions do
  fab!(:user) { Fabricate(:user) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key)) }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }
  let(:response) do
    {
      resource: resource.name,
      product_id: SecureRandom.hex(8),
      product_name: "Business Subscription",
      price_id: SecureRandom.hex(8),
      price_name: "Yearly"
    }
  end

  it "updates subscriptions" do
    stub_subscription_request(200, resource, response)
    described_class.update

    subscription = SubscriptionClientSubscription.find_by(product_id: response[:product_id])
    expect(subscription.present?).to eq(true)
    expect(subscription.active).to eq(true)
  end

  it "deactivates subscriptions" do
    old_sub = Fabricate(:subscription_client_subscription)
    stub_subscription_request(200, resource, response)
    described_class.update

    subscription = SubscriptionClientSubscription.find_by(product_id: old_sub.product_id)
    expect(subscription.present?).to eq(true)
    expect(subscription.active).to eq(false)
  end

  it "handles subscription http errors" do
    stub_subscription_request(404, resource, {})
    described_class.update

    expect(SubscriptionClientSubscription.exists?(product_id: response[:product_id])).to eq(false)
  end
end
