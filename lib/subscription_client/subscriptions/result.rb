# frozen_string_literal: true

class ::SubscriptionClient::Subscriptions::Result
  REQUIRED_KEYS ||= %i(
    resource
    product_id
    price_id
  )
  OPTIONAL_KEYS ||= %i(
    product_name
    price_name
  )
  KEYS ||= REQUIRED_KEYS + OPTIONAL_KEYS

  attr_reader :errors,
              :info

  def initialize
    @errors = []
    @info = []
  end

  def not_authorized(supplier)
    error("not_authorized", supplier)
  end

  def retrieve_subscriptions(supplier, raw_data)
    subscriptions_data = raw_data[:subscriptions].compact

    unless subscriptions_data.present? && subscriptions_data.is_a?(Array)
      error("invalid_response", supplier)
      return nil
    end

    subscriptions_data
      .map(&:symbolize_keys)
      .select { |data| validate_subscription_data(data) }
      .map { |data| data.slice(*KEYS) }
      .reject(&:empty?)
  end

  def validate_subscription_data(subscription_data)
    REQUIRED_KEYS.all? { |key| subscription_data.has_key?(key) }
  end

  def with_resources(supplier, subscription_data)
    resources = SubscriptionClientResource.where(
      supplier_id: supplier.id,
      name: subscription_data.map { |data| data[:resource] }
    )

    subscription_data.reduce([]) do |subs, data|
      matching_resource = resources.select { |resource| resource.name === data[:resource] }.first

      if matching_resource.present?
        data[:resource_id] = matching_resource.id
        subs << data.except(:resource)
      else
        info("no_resource", supplier, resource: data[:resource])
      end

      subs
    end
  end

  def connection_error(supplier)
    error("supplier_connection", supplier)
  end

  def no_suppliers
    info("no_suppliers")
  end

  def no_subscriptions(supplier)
    info("no_subscriptions", supplier)
  end

  def updated_subscription(supplier, subscription_ids: nil)
    info("updated_subscription", supplier, subscription_ids: subscription_ids)
  end

  def created_subscription(supplier, subscription_ids: nil)
    info("created_subscription", supplier, subscription_ids: subscription_ids)
  end

  def failed_to_create_subscription(supplier, subscription_ids: nil)
    info("failed_to_create_subscription", supplier, subscription_ids: subscription_ids)
  end

  def info(key, supplier = nil, subscription_ids: nil, resource: nil)
    attrs = {}

    if supplier
      attrs = {
        supplier: supplier.name,
        supplier_url: supplier.url
      }
    end

    attrs.merge!(subscription_ids) if subscription_ids.present?
    attrs[:resource] if resource.present?

    @info << I18n.t("subscription_client.subscriptions.info.#{key}", attrs)
  end

  def error(key, supplier)
    @errors << I18n.t("subscription_client.subscriptions.error.#{key}", supplier: supplier.name, supplier_url: supplier.url)
  end
end
