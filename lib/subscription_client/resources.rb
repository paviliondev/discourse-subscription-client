# frozen_string_literal: true

class SubscriptionClient::Resources
  attr_accessor :suppliers,
                :resources

  def initialize
    @suppliers = []
    @resources = []
  end

  def self.find_all
    RailsMultisite::ConnectionManagement.each_connection do
      self.new.find_all
    end
  end

  def find_all
    return unless SubscriptionClient.database_exists?

    setup_resources
    find_resources

    if @resources.any?
      ActiveRecord::Base.transaction do
        find_suppliers
        save_resources
      end
    end
  end

  def setup_resources
    setup_plugins
  end

  def find_resources
    resources = find_plugins
    resources.each do |r|
      @resources << {
        name: r[:name],
        supplier_url: r[:supplier_url]
      }
    end
  end

  def find_suppliers
    supplier_urls = @resources.map { |resource| resource[:supplier_url] }.uniq.compact
    supplier_urls.each do |url|
      supplier = SubscriptionClientSupplier.find_or_create_by(url: url)
      request = SubscriptionClient::Request.new(:supplier, supplier.id)
      data = request.perform("#{url}/subscription-server")

      if valid_supplier_data?(data)
        supplier.update(name: data[:supplier], products: data[:products])
        @suppliers << supplier
      end
    end
  end

  def save_resources
    @resources.each do |resource|
      supplier = @suppliers.select { |s| s.url === resource[:supplier_url] }.first

      if supplier.present?
        attrs = {
          supplier_id: supplier.id,
          name: resource[:name]
        }
        unless SubscriptionClientResource.exists?(attrs)
          SubscriptionClientResource.create!(attrs)
        end
      end
    end
  end

  def setup_plugins
    Plugin::Metadata::FIELDS << :subscription_url unless Plugin::Metadata::FIELDS.include?(:subscription_url)
    Plugin::Metadata.attr_accessor(:subscription_url)
  end

  def find_plugins
    plugins = []
    Dir["#{SubscriptionClient.root}/plugins/*/plugin.rb"].sort.each do |path|
      source = File.read(path)
      metadata = Plugin::Metadata.parse(source)
      next unless metadata.subscription_url.present?

      plugins << {
        name: metadata.name,
        supplier_url: ENV["TEST_SUBSCRIPTION_URL"] || metadata.subscription_url
      }
    end
    plugins
  end

  def valid_supplier_data?(data)
    return false unless data.present? && data.is_a?(Hash)
    return false unless %i[supplier products].all? { |key| data.key?(key) }
    return false unless data[:supplier].is_a?(String)
    return false unless data[:products].is_a?(Hash)

    data[:products].all? do |resource, products|
      products.is_a?(Array) &&
        products.all? do |product|
          %i[product_id product_slug].all? do |key|
            product.key?(key) && product[key].is_a?(String)
          end
        end
    end
  end
end
