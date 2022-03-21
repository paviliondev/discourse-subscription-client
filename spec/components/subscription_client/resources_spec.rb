# frozen_string_literal: true

require_relative '../../plugin_helper'

describe SubscriptionClient::Resources do
  before do
    SubscriptionClient.stubs(:root).returns("#{Rails.root}/plugins/discourse-subscription-client/spec/fixtures")
  end

  it "finds all resources" do
    stub_server_request("https://plugins.discourse.pavilion.tech", "Pavilion")
    SubscriptionClient::Resources.find_all
    expect(SubscriptionClientSupplier.exists?(name: "Pavilion")).to eq(true)
    expect(SubscriptionClientResource.exists?(name: "subscription-plugin")).to eq(true)
  end
end
