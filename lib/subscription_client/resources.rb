# frozen_string_literal: true

class SubscriptionClient::Resources
  attr_accessor :suppliers,
                :resources

  def initialize
    @suppliers = []
    @resources = []
  end

  def self.find_all
    new.find_all
  end

  def find_all
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
    find_plugins
  end

  def find_suppliers
    supplier_urls = @resources.map { |resource| resource[:supplier_url] }.uniq

    supplier_urls.each do |result, url|
      supplier = SubscriptionClientSupplier.find_by(url: url)

      if supplier && supplier.name
        @suppliers << supplier
      else
        supplier = supplier || SubscriptionClientSupplier.create!(url: url)
        request = SubscriptionClient::Request.new(:supplier, supplier.id)
        response = request.perform("#{url}/subscription-server")

        if response.status === 200
          data = JSON.parse(response.body)
          supplier.update(name: data['supplier'])

          @suppliers << supplier
        end
      end
    end
  end

  def save_resources
    @resources.each do |resource|
      supplier = @suppliers.select { |supplier| supplier.url === resource[:supplier_url] }.first

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
    Dir["#{SubscriptionClient.root}/plugins/*/plugin.rb"].sort.each do |path|
      source = File.read(path)
      metadata = Plugin::Metadata.parse(source)

      if metadata.subscription_url.present?
        @resources << {
          name: metadata.name,
          supplier_url: metadata.subscription_url
        }
      end
    end
  end
end
