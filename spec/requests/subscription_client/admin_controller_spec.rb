# frozen_string_literal: true
require_relative '../../plugin_helper'

describe SubscriptionClient::AdminController do
  fab!(:user) { Fabricate(:user, admin: true) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key)) }
  fab!(:resource) { Fabricate(:subscription_client_resource, supplier: supplier) }
  fab!(:subscription) { Fabricate(:subscription_client_subscription, resource: resource) }
  fab!(:notice) { Fabricate(:subscription_client_notice, notice_subject: resource) }
  fab!(:featured_notice) { Fabricate(:subscription_client_notice, notice_subject: supplier) }

  before do
    sign_in(user)
  end

  it "#index" do
    get "/admin/plugins/subscription-client"
    expect(response.status).to eq(200)
    expect(response.parsed_body['active_notice_count']).to eq(2)
    expect(response.parsed_body['featured_notices'].count).to eq(1)
    expect(response.parsed_body['featured_notices'][0]['title']).to eq(featured_notice.title)
  end
end
