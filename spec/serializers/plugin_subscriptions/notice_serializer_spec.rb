# frozen_string_literal: true

require_relative '../../plugin_helper'

describe PluginSubscriptions::NoticeSerializer do
  let(:notice) {
    PluginSubscriptions::Notice.new(
      message: "Message about subscription",
      type: "info",
      created_at: Time.now - 3.day,
      expired_at: nil
    )
  }

  it 'should return notice attributes' do
    serialized_notice = described_class.new(notice)
    expect(serialized_notice.message).to eq(notice.message)
    expect(serialized_notice.type).to eq(PluginSubscriptions::Notice.types.key(notice.type))
    expect(serialized_notice.dismissable).to eq(true)
  end
end
