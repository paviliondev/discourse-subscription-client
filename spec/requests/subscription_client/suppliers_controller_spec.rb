# frozen_string_literal: true
require_relative '../../plugin_helper'

describe SubscriptionClient::SuppliersController do
  fab!(:admin) { Fabricate(:user, admin: true) }
  fab!(:moderator) { Fabricate(:user, moderator: true) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier) }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }
  let!(:products) { { "subscription-plugin": [{ product_id: "prod_CBTNpi3fqWWkq0", product_slug: "business" }] } }
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

  context "with admin" do
    before do
      sign_in(admin)
    end

    before(:each) do
      SubscriptionClient::Resources.any_instance.stubs(:find_plugins).returns([{ name: supplier.name, url: supplier.url }])
      stub_server_request(supplier.url, supplier: supplier, products: products, status: 200)
    end

    it "lists suppliers" do
      get "/admin/plugins/subscription-client/suppliers.json"
      expect(response.status).to eq(200)
      expect(response.parsed_body['suppliers'].size).to eq(1)
      expect(response.parsed_body['suppliers'].first['name']).to eq(supplier.name)
    end

    it "authorizes" do
      get "/admin/plugins/subscription-client/suppliers/authorize", params: { supplier_id: supplier.id }
      expect(response.status).to eq(302)
      expect(cookies[:user_api_request_id].present?).to eq(true)
    end

    it "handles authorization callbacks" do
      request_id = cookies[:user_api_request_id] = SubscriptionClient::Authorization.request_id(supplier.id)
      payload = generate_auth_payload(admin.id, request_id)
      stub_subscription_request(200, resource, subscription_response)

      get "/admin/plugins/subscription-client/suppliers/authorize/callback", params: { payload: payload }
      expect(response).to redirect_to("/admin/plugins/subscription-client/subscriptions")

      subscription = SubscriptionClientSubscription.find_by(resource_id: resource.id)
      expect(subscription.present?).to eq(true)
      expect(subscription.subscribed).to eq(true)
    end

    before do
      resource.supplier.products = nil
      resource.save!
      supplier.products = nil
      supplier.save!
    end

    it "handles authorization callbacks and deals with legacy data record" do
      request_id = cookies[:user_api_request_id] = SubscriptionClient::Authorization.request_id(supplier.id)
      payload = generate_auth_payload(admin.id, request_id)
      stub_subscription_request(200, resource, subscription_response)

      original_supplier = SubscriptionClientSupplier.first
      expect(original_supplier.products).to eq(nil)

      get "/admin/plugins/subscription-client/suppliers/authorize/callback", params: { payload: payload }
      expect(response).to redirect_to("/admin/plugins/subscription-client/subscriptions")
      subscription = SubscriptionClientSubscription.find_by(resource_id: resource.id)
      updated_supplier = SubscriptionClientSupplier.first

      expect(subscription.present?).to eq(true)
      expect(subscription.subscribed).to eq(true)
      expect(updated_supplier.products).not_to eq(nil)
    end

    it "destroys authorizations" do
      request_id = SubscriptionClient::Authorization.request_id(supplier.id)
      payload = generate_auth_payload(admin.id, request_id)
      SubscriptionClient::Authorization.process_response(request_id, payload)

      delete "/admin/plugins/subscription-client/suppliers/authorize", params: { supplier_id: supplier.id }
      expect(response.status).to eq(200)
      expect(supplier.authorized?).to eq(false)
    end
  end

  context "with moderator allowed to manage subscriptions" do
    before do
      SiteSetting.subscription_client_allow_moderator_subscription_management = true
      sign_in(moderator)
    end

    before(:each) do
      SubscriptionClient::Resources.any_instance.stubs(:find_plugins).returns([{ name: supplier.name, url: supplier.url }])
      stub_server_request(supplier.url, supplier: supplier, products: products, status: 200)
    end

    it "doesnt allow access" do
      get "/admin/plugins/subscription-client/suppliers.json"
      expect(response.status).to eq(403)
    end

    context "with subscription_client_allow_moderator_supplier_management enabled" do
      before do
        SiteSetting.subscription_client_allow_moderator_supplier_management = true
      end

      it "lists suppliers" do
        get "/admin/plugins/subscription-client/suppliers.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body['suppliers'].size).to eq(1)
      end

      it "authorizes" do
        get "/admin/plugins/subscription-client/suppliers/authorize", params: { supplier_id: supplier.id }
        expect(response.status).to eq(302)
        expect(cookies[:user_api_request_id].present?).to eq(true)
      end

      it "handles authorization callbacks" do
        request_id = cookies[:user_api_request_id] = SubscriptionClient::Authorization.request_id(supplier.id)
        payload = generate_auth_payload(moderator.id, request_id)
        stub_subscription_request(200, resource, subscription_response)

        get "/admin/plugins/subscription-client/suppliers/authorize/callback", params: { payload: payload }
        expect(response).to redirect_to("/admin/plugins/subscription-client/subscriptions")

        subscription = SubscriptionClientSubscription.find_by(resource_id: resource.id)
        expect(subscription.present?).to eq(true)
        expect(subscription.subscribed).to eq(true)
      end

      it "destroys authorizations" do
        request_id = SubscriptionClient::Authorization.request_id(supplier.id)
        payload = generate_auth_payload(moderator.id, request_id)
        SubscriptionClient::Authorization.process_response(request_id, payload)

        delete "/admin/plugins/subscription-client/suppliers/authorize", params: { supplier_id: supplier.id }
        expect(response.status).to eq(200)
        expect(supplier.authorized?).to eq(false)
      end
    end
  end
end
