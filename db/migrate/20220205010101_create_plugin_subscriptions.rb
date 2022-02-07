# frozen_string_literal: true

class CreatePluginSubscriptions < ActiveRecord::Migration[5.2]
  def change

    create_table :plugin_subscriptions do |t|
      t.string :unique_id, null: false
      t.string :supplier_name
      t.string :product_id, null: false
      t.string :product_name, null: false
      t.string :product_name_slug, null: false
      t.string :price_id, null: false
      t.string :price_nickname, null: false
      t.string :price_nickname_slug, null: false
      t.boolean :active, default: false, null: false
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :plugin_subscriptions, :unique_id, unique: true
  end
end
