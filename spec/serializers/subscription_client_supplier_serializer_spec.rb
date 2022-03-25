# frozen_string_literal: true

require_relative '../plugin_helper'

describe SubscriptionClientSupplierSerializer do
  fab!(:supplier) { Fabricate(:subscription_client_supplier) }

  it 'should return supplier attributes' do
    serialized_supplier = described_class.new(supplier)
    expect(serialized_supplier.name).to eq(supplier.name)
    expect(serialized_supplier.user.username).to eq(supplier.user.username)
    expect(serialized_supplier.authorized_at).to eq_time(supplier.authorized_at)
  end
end
