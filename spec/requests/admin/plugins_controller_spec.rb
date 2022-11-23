# frozen_string_literal: true
require_relative '../../plugin_helper'

describe Admin::PluginsController do
  fab!(:moderator) { Fabricate(:user, moderator: true) }
  fab!(:admin) { Fabricate(:user, admin: true) }

  context "with moderator" do
    before do
      sign_in(moderator)
    end

    context "when cannot manage subscriptions" do
      before do
        SiteSetting.subscription_client_allow_moderator_subscription_management = false
      end

      it "does not serialize the plugin" do
        get "/admin/plugins.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body['plugins'].select { |p| p['id'] == "discourse-subscription-client" }.size).to eq(0)
      end
    end

    context "when can manage subscriptions" do
      before do
        SiteSetting.subscription_client_allow_moderator_subscription_management = true
      end

      it "serializes the plugin" do
        get "/admin/plugins.json"
        expect(response.status).to eq(200)
        expect(response.parsed_body['plugins'].select { |p| p['id'] == "discourse-subscription-client" }.size).to eq(1)
      end
    end
  end

  context "with admin" do
    before do
      sign_in(admin)
    end

    it "serializes the plugin" do
      get "/admin/plugins.json"
      expect(response.status).to eq(200)
      expect(response.parsed_body['plugins'].select { |p| p['id'] == "discourse-subscription-client" }.size).to eq(1)
    end
  end
end
