# frozen_string_literal: true

require_relative '../../plugin_helper'

describe PluginSubscriptions::SubscriptionSerializer do
  it 'should return subscription attributes' do
    subscriptions = PluginSubscriptions::Subscriptions.new
    serialized = described_class.new(subscriptions, root: false)

    expect(serialized.authentication.class).to eq(PluginSubscriptions::Authentication)
    expect(serialized.subscriptions.class).to eq(PluginSubscriptions::Subscriptions)
  end
end
