# frozen_string_literal: true

class CreateSubscriptionClientResources < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_client_resources do |t|
      t.references :supplier, foreign_key: { to_table: :subscription_client_suppliers } # rubocop:disable Discourse/NoAddReferenceOrAliasesActiveRecordMigration
      t.string :name, null: false

      t.timestamps
    end

    add_index :subscription_client_resources, [:supplier_id, :name], unique: true
  end
end
