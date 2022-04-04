# frozen_string_literal: true

require_relative '../../plugin_helper'

describe SubscriptionClient::Request do
  fab!(:user) { Fabricate(:user) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key)) }
  fab!(:resource) { Fabricate(:subscription_client_resource, name: 'discourse-custom-wizard', supplier: supplier) }
  fab!(:subscription) { Fabricate(:subscription_client_subscription, resource: resource, active: true) }
  let(:subscription_message) {
    {
      title: "Title of message about subscription",
      message: "Message about subscription",
      notice_type: "info",
      created_at: Time.now - 3.day,
      expired_at: nil
    }
  }
  let(:plugin_status) {
    {
      name: 'discourse-custom-wizard',
      status: 'incompatible',
      status_changed_at: Time.now - 3.day
    }
  }

  before do
    freeze_time
    SiteSetting.subscription_client_request_plugin_statuses = true
  end

  it "creates an error if connection to notice server fails" do
    stub_plugin_status_request(400, {})
    SubscriptionClient::Notices.update(subscription: false)

    expect(described_class.current_error(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID).present?).to eq(true)
  end

  it "only creates one connection error per type at a time" do
    stub_subscription_messages_request(supplier, 400, [])
    stub_plugin_status_request(400, {})

    5.times { SubscriptionClient::Notices.update }

    expect(described_class.current_error(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)[:count]).to eq(5)
  end

  it "creates a connection error notice if connection errors reach limit" do
    stub_plugin_status_request(400, {})

    request = described_class.new(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)
    request.limit.times { SubscriptionClient::Notices.update(subscription: false) }
    notice = SubscriptionClientNotice.list(notice_type: SubscriptionClientNotice.types[:connection_error]).first

    expect(request.current_error[:count]).to eq(request.limit)
    expect(notice.notice_type).to eq(SubscriptionClientNotice.types[:connection_error])
  end

  it "deactivates all supplier's subscriptions if supplier connection error limit is reached" do
    stub_subscription_messages_request(supplier, 400, [])
    request = described_class.new(:supplier, supplier.id)
    request.limit.times { SubscriptionClient::Notices.update(plugin: false) }
    expect(subscription.active?).to eq(false)
  end

  it "expires a connection error notice if connection succeeds" do
    stub_plugin_status_request(400, {})
    request = described_class.new(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)
    request.limit.times { SubscriptionClient::Notices.update(subscription: false) }

    stub_plugin_status_request(200, { statuses: [plugin_status], total: 1 })
    SubscriptionClient::Notices.update(subscription: false)
    notice = SubscriptionClientNotice.list(notice_type: SubscriptionClientNotice.types[:connection_error], include_all: true).first

    expect(notice.notice_type).to eq(SubscriptionClientNotice.types[:connection_error])
    expect(notice.expired?).to eq(true)
  end
end
