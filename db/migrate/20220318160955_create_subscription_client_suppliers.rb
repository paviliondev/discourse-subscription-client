class CreateSubscriptionClientSuppliers < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_client_suppliers do |t|
      t.string :name
      t.string :url, null: false
      t.string :api_key
      t.datetime :user_id
      t.datetime :authorized_at

      t.timestamps
    end

    add_index :subscription_client_suppliers, [:url], unique: true
  end
end
