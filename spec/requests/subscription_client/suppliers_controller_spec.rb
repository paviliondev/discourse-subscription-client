# frozen_string_literal: true
require_relative '../../plugin_helper'

describe SubscriptionClient::SuppliersController do
  fab!(:user) { Fabricate(:user, admin: true) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier) }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }
  let(:subscription_response) do
    {
      resource: resource.name,
      product_id: SecureRandom.hex(8),
      product_name: "Business Subscription",
      price_id: SecureRandom.hex(8),
      price_name: "Yearly"
    }
  end

  before do
    sign_in(user)
  end

  it "#authorize" do
    get "/admin/plugins/subscription-client/suppliers/authorize", params: { supplier_id: supplier.id }
    expect(response.status).to eq(302)
    expect(cookies[:user_api_request_id].present?).to eq(true)
  end

  it "#authorize_callback" do
    request_id = cookies[:user_api_request_id] = SubscriptionClient::Authorization.request_id(supplier.id)
    payload = generate_auth_payload(user.id, request_id)
    stub_subscription_request(200, resource, subscription_response)

    get "/admin/plugins/subscription-client/suppliers/authorize/callback", params: { payload: payload }
    expect(response).to redirect_to("/admin/plugins/subscription-client/subscriptions")

    subscription = SubscriptionClientSubscription.find_by(resource_id: resource.id)
    expect(subscription.present?).to eq(true)
    expect(subscription.active).to eq(true)
  end

  it "#destroy" do
    request_id = SubscriptionClient::Authorization.request_id(supplier.id)
    payload = generate_auth_payload(user.id, request_id)
    SubscriptionClient::Authorization.process_response(request_id, payload)

    delete "/admin/plugins/subscription-client/suppliers/authorize", params: { supplier_id: supplier.id }
    expect(response.status).to eq(200)
    expect(supplier.authorized?).to eq(false)
  end
end
