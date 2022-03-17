# frozen_string_literal: true
require_relative '../../../plugin_helper'

describe PluginSubscriptions::AdminNoticeController do
  fab!(:admin_user) { Fabricate(:user, admin: true) }
  let(:subscription_message_notice) {
    {
      title: "Title of message about subscription",
      message: "Message about subscription",
      type: 0,
      created_at: Time.now.iso8601(3),
      expired_at: nil
    }
  }
  let(:plugin_status_notice) {
    {
      title: "The Custom Wizard Plugin is incompatibile with the latest version of Discourse.",
      message: "Please check the Custom Wizard Plugin status on [localhost:3000](http://localhost:3000) before updating Discourse.",
      type: 1,
      archetype: 1,
      created_at: Time.now.iso8601(3),
      expired_at: nil
    }
  }

  before do
    sign_in(admin_user)
  end

  it "lists notices" do
    @notice = PluginSubscriptions::Notice.new(subscription_message_notice)
    @notice.save

    get "/admin/plugins/plugin-subs/notice.json"
    expect(response.status).to eq(200)
    expect(response.parsed_body.length).to eq(1)
  end

  it "dismisses notices" do
    @notice = PluginSubscriptions::Notice.new(subscription_message_notice)
    @notice.save

    put "/admin/plugins/plugin-subs/notice/#{@notice.id}/dismiss.json"
    expect(response.status).to eq(200)

    updated = PluginSubscriptions::Notice.find(@notice.id)
    expect(updated.dismissed?).to eq(true)
  end

  it "dismisses all notices" do
    5.times do |index|
      subscription_message_notice[:title] += " #{index}"
      @notice = PluginSubscriptions::Notice.new(subscription_message_notice)
      @notice.save
    end

    put "/admin/plugins/plugin-subs/notice/dismiss.json"
    expect(response.status).to eq(200)
    expect(PluginSubscriptions::Notice.list.size).to eq(0)
  end

  it "hides notices" do
    @notice = PluginSubscriptions::Notice.new(plugin_status_notice)
    @notice.save

    put "/admin/plugins/plugin-subs/notice/#{@notice.id}/hide.json"
    expect(response.status).to eq(200)

    updated = PluginSubscriptions::Notice.find(@notice.id)
    expect(updated.hidden?).to eq(true)
  end
end
