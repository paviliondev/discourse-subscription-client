# frozen_string_literal: true

require_relative '../../plugin_helper'

describe SubscriptionClient::Notices do
  fab!(:user) { Fabricate(:user) }
  fab!(:supplier) { Fabricate(:subscription_client_supplier, api_key: Fabricate(:subscription_client_user_api_key)) }
  fab!(:resource) { Fabricate(:subscription_client_resource, name: 'discourse-custom-wizard', supplier_id: supplier.id)}
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

  context "subscription" do
    before do
      freeze_time
      stub_request(:get, supplier.url).to_return(status: 200, body: { messages: [subscription_message] }.to_json)
      described_class.update(plugin: false)
    end

    it "converts subscription messages into notices" do
      notice = SubscriptionClientNotice.list.first
      expect(notice.notice_type).to eq(SubscriptionClientNotice.types[:info])
      expect(notice.message).to eq(subscription_message[:message])
      expect(notice.changed_at.to_datetime).to be_within(1.second).of (subscription_message[:created_at].to_datetime)
    end

    it "expires notice if subscription message is expired" do
      subscription_message[:expired_at] = Time.now
      stub_request(:get, supplier.url).to_return(status: 200, body: { messages: [subscription_message] }.to_json)
      described_class.update(plugin: false)

      notice = SubscriptionClientNotice.list(include_all: true).first
      expect(notice.expired?).to eq(true)
    end

    it "dismisses informational subscription notices" do
      notice = SubscriptionClientNotice.list(include_all: true).first
      expect(notice.dismissed?).to eq(false)

      notice.dismiss!
      expect(notice.dismissed?).to eq(true)
    end

    it "dismisses all informational subscription notices" do
      4.times do |index|
        subscription_message[:title] += " #{index}"
        subscription_message[:created_at] = subscription_message[:created_at] + (index + 1)
        stub_request(:get, supplier.url).to_return(status: 200, body: { messages: [subscription_message] }.to_json)
        described_class.update(plugin: false)
      end
      expect(SubscriptionClientNotice.list.count).to eq(5)
      SubscriptionClientNotice.dismiss_all
      expect(SubscriptionClientNotice.list.count).to eq(0)
    end
  end

  context "plugin status" do
    before do
      freeze_time
      stub_plugin_status_request(200, { statuses: [plugin_status], total: 1})
      described_class.update(subscription: false)
    end

    it "converts warning into notice" do
      notice = SubscriptionClientNotice.list.first
      expect(notice.notice_type).to eq(SubscriptionClientNotice.types[:warning])
      expect(notice.message).to eq(I18n.t("subscription_client.notices.compatibility_issue.message", url: SubscriptionClient.plugin_status_server_url))
      expect(notice.changed_at.to_datetime).to be_within(1.second).of (plugin_status[:status_changed_at].to_datetime)
    end

    it "expires warning notices if status is recommended or compatible" do
      plugin_status[:status] = 'compatible'
      plugin_status[:status_changed_at] = Time.now
      stub_plugin_status_request(200, { statuses: [plugin_status], total: 1})
      described_class.update(subscription: false)

      notice = SubscriptionClientNotice.list(notice_type: SubscriptionClientNotice.types[:warning], include_all: true).first
      expect(notice.expired?).to eq(true)
    end

    it "hides plugin status warnings" do
      notice = SubscriptionClientNotice.list.first
      expect(notice.hidden?).to eq(false)

      notice.hide!
      expect(notice.hidden?).to eq(true)
    end
  end

  it "lists notices not expired more than a day ago" do
    subscription_message[:expired_at] = Time.now - 8.hours
    stub_request(:get, supplier.url).to_return(status: 200, body: { messages: [subscription_message] }.to_json)
    stub_plugin_status_request(200, { statuses: [plugin_status], total: 1})

    described_class.update
    expect(SubscriptionClientNotice.list(include_all: true).length).to eq(2)
  end

  context "connection errors" do
    before do
      freeze_time
    end

    it "creates an error if connection to notice server fails" do
      stub_plugin_status_request(400, {})
      described_class.update(subscription: false)

      expect(SubscriptionClient::Request.current_error(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID).present?).to eq(true)
    end

    it "only creates one connection error per type at a time" do
      stub_request(:get, supplier.url).to_return(status: 400, body: { messages: [subscription_message] }.to_json)
      stub_plugin_status_request(400, {})

      5.times { described_class.update }

      expect(SubscriptionClient::Request.current_error(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)[:count]).to eq(5)
      expect(SubscriptionClient::Request.current_error(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)[:count]).to eq(5)
    end

    it "creates a connection error notice if connection errors reach limit" do
      stub_plugin_status_request(400, {})

      request = SubscriptionClient::Request.new(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)
      request.limit.times { described_class.update(subscription: false) }
      notice = SubscriptionClientNotice.list(notice_type: SubscriptionClientNotice.types[:connection_error]).first

      expect(request.current_error[:count]).to eq(request.limit)
      expect(notice.notice_type).to eq(SubscriptionClientNotice.types[:connection_error])
    end

    it "expires a connection error notice if connection succeeds" do
      stub_plugin_status_request(400, {})
      request = SubscriptionClient::Request.new(:resource, SubscriptionClient::Notices::PLUGIN_STATUS_RESOURCE_ID)
      request.limit.times { described_class.update(subscription: false) }

      stub_plugin_status_request(200, { statuses: [plugin_status], total: 1})
      described_class.update(subscription: false)
      notice = SubscriptionClientNotice.list(notice_type: SubscriptionClientNotice.types[:connection_error], include_all: true).first

      expect(notice.notice_type).to eq(SubscriptionClientNotice.types[:connection_error])
      expect(notice.expired_at.present?).to eq(true)
    end
  end
end