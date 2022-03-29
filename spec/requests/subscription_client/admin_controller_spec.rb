# frozen_string_literal: true
require_relative '../../plugin_helper'

describe SubscriptionClient::AdminController do
  fab!(:user) { Fabricate(:user, admin: true) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key), authorized_at: Time.now, user: user) }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }

  before do
    sign_in(user)
  end

  it "#index" do
    get "/admin/plugins/subscription-client.json"
    expect(response.status).to eq(200)
    expect(response.parsed_body['authorized_supplier_count']).to eq(1)
    expect(response.parsed_body['resource_count']).to eq(1)
  end
end
