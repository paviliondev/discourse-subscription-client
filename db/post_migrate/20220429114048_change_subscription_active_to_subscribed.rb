# frozen_string_literal: true
class ChangeSubscriptionActiveToSubscribed < ActiveRecord::Migration[7.0]
  def change
    rename_column :subscription_client_subscriptions, :active, :subscribed
  end
end
