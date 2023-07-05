# frozen_string_literal: true
require_relative '../../plugin_helper'

describe SubscriptionClient::SubscriptionsController do
  fab!(:user) { Fabricate(:user, admin: true) }
  fab!(:authorized_at) { Time.now }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key), authorized_at: authorized_at, user: user) }
  let!(:products) { { "subscription-plugin": [{ product_id: "prod_CBTNpi3fqWWkq0", product_slug: "business" }] } }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }
  fab!(:subscription) { Fabricate(:subscription_client_subscription, resource: resource) }
  let(:subscription_response) do
    {
      subscriptions: [
        {
          resource: resource.name,
          product_id: SecureRandom.hex(8),
          product_name: "Business Subscription",
          price_id: SecureRandom.hex(8),
          price_name: "Yearly"
        }
      ]
    }
  end

  before do
    sign_in(user)
  end

  it "returns subscriptions" do
    get "/admin/plugins/subscription-client/subscriptions.json"
    expect(response.status).to eq(200)
    expect(response.parsed_body.size).to eq(1)
  end

  before do
    SubscriptionClient::Resources.any_instance.stubs(:find_plugins).returns([{ name: resource.name, supplier_url: supplier.url }])
    stub_server_request(supplier.url, supplier: supplier, products: products, status: 200)
  end

  it "updates subscriptions and fixes legacy supplier data" do
    stub_subscription_request(200, resource, subscription_response)
    old_supplier_record = SubscriptionClientSupplier.first
    old_supplier_record.update(products: nil)

    expect(SubscriptionClientSupplier.first.products).to eq(nil)
    post "/admin/plugins/subscription-client/subscriptions.json"
    expect(response.status).to eq(200)
    expect(subscription.subscribed).to eq(false)
    expect(SubscriptionClientSupplier.first.products).not_to eq(nil)
  end

  it "updates subscriptions" do
    stub_subscription_request(200, resource, { subscriptions: [] })
    post "/admin/plugins/subscription-client/subscriptions.json"
    expect(response.status).to eq(200)
    expect(subscription.subscribed).to eq(false)
  end
end
