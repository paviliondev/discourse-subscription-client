# frozen_string_literal: true
require_relative '../../plugin_helper'

describe SubscriptionClient::AdminController do
  fab!(:admin) { Fabricate(:user, admin: true) }
  fab!(:moderator) { Fabricate(:user, moderator: true) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key), authorized_at: Time.now, user: admin) }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }

  context "with admin" do
    before do
      sign_in(admin)
    end

    it "returns the authorized supplier count and resource count" do
      get "/admin/plugins/subscription-client.json"
      expect(response.status).to eq(200)
      expect(response.parsed_body['authorized_supplier_count']).to eq(1)
      expect(response.parsed_body['resource_count']).to eq(1)
    end
  end

  context "with moderator" do
    before do
      sign_in(moderator)
    end

    it "doesnt allow access" do
      get "/admin/plugins/subscription-client.json"
      expect(response.status).to eq(403)
    end

    context "with subscription_client_allow_moderator_supplier_management enabled" do
      before do
        SiteSetting.subscription_client_allow_moderator_subscription_management = true
      end

      it "returns the authorized supplier count and resource count" do
        get "/admin/plugins/subscription-client.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body['authorized_supplier_count']).to eq(1)
        expect(response.parsed_body['resource_count']).to eq(1)
      end
    end
  end
end
