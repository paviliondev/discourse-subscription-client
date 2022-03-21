# frozen_string_literal: true

class SubscriptionClient::Subscriptions
  def initialize
    @suppliers = SubscriptionClientSupplier.with_keys
  end

  def self.update
    new.update
  end

  def update
    return if !SiteSetting.subscription_client_enabled

    @result = SubscriptionClient::Subscriptions::Result.new

    if @suppliers.blank?
      @result.no_suppliers
    else
      @suppliers.each do |supplier|
        update_supplier(supplier)
      end
    end

    if @result.errors.any?
      @result.errors.each do |error|
        Rails.logger.error "SubscriptionClient::Subscriptions.update: #{error}"
      end
    end

    if SiteSetting.subscription_client_verbose_logs && @result.info.any?
      @result.info.each do |info|
        Rails.logger.info "SubscriptionClient::Subscriptions.update: #{info}"
      end
    end
  end

  def update_supplier(supplier)
    return @result.not_authorized(supplier) if supplier.api_key.blank?

    headers = { "User-Api-Key" => supplier.api_key }
    url = "#{supplier.url}/subscription-server/user-subscriptions"
    request = SubscriptionClient::Request.new(:resource, supplier.id)
    response = request.perform(url, headers: headers)
    byebug
    return @result.connection_error(supplier) if response.nil?

    subscription_data = @result.retrieve_subscriptions(supplier, response)
    return if @result.errors.any?
    return @result.no_subscriptions(supplier) if subscription_data.blank?

    @result.with_resources(supplier, subscription_data).each do |data|
      required_keys = data.slice(SubscriptionClient::Subscriptions::Result::REQUIRED_KEYS)
      subscription = SubscriptionClientSubscription.find_by(required_keys)

      if subscription.present?
        subscription.touch
        @result.updated_subscription(supplier, subscription_ids: required_keys)
      else
        subscription = SubscriptionClientSubscription.create!(data.merge(active: true))

        if subscription
          @result.created_subscription(supplier, subscription_ids: required_keys)
        else
          @result.failed_to_create_subscription(supplier, subscription_ids: required_keys)
        end
      end
    end
  end
end
