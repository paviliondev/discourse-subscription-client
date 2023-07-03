# frozen_string_literal: true

require_relative '../../plugin_helper'

describe SubscriptionClient::Resources, type: :multisite do
  let!(:supplier) { { name: "Pavilion" } }
  let!(:products) { { "subscription-plugin": [{ product_id: "prod_CBTNpi3fqWWkq0", product_slug: "business" }] } }

  before do
    SubscriptionClient.stubs(:root).returns("#{Rails.root}/plugins/discourse-subscription-client/spec/fixtures")
    SubscriptionClient::Resources.any_instance.stubs(:find_plugins).returns([{ name: "subscription-plugin", supplier_url: "https://coop.pavilion.tech" }])
  end

  it "finds all resources in all multisite instances" do
    test_multisite_connection("default") do
      stub_server_request("https://coop.pavilion.tech", supplier: supplier, products: products)
      SubscriptionClient::Resources.find_all

      supplier = SubscriptionClientSupplier.find_by(name: "Pavilion")
      expect(supplier.present?).to eq(true)
      expect(supplier.products).to eq(products.as_json)
      expect(SubscriptionClientResource.exists?(name: "subscription-plugin")).to eq(true)
    end

    test_multisite_connection("second") do
      stub_server_request("https://coop.pavilion.tech", supplier: supplier, products: products)
      SubscriptionClient::Resources.find_all

      supplier = SubscriptionClientSupplier.find_by(name: "Pavilion")
      expect(supplier.present?).to eq(true)
      expect(supplier.products).to eq(products.as_json)
      expect(SubscriptionClientResource.exists?(name: "subscription-plugin")).to eq(true)
    end
  end

  it "handles failed requests" do
    stub_server_request("https://coop.pavilion.tech", status: 404)
    SubscriptionClient::Resources.find_all

    supplier = SubscriptionClientSupplier.find_by(name: "Pavilion")
    expect(supplier.present?).to eq(false)
    expect(SubscriptionClientResource.exists?(name: "subscription-plugin")).to eq(false)
  end
end
