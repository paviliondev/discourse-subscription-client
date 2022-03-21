# frozen_string_literal: true

class SubscriptionClient::Request
  SUPPLIER_ERROR_LIMIT = 2
  RESOURCE_ERROR_LIMIT = 5
  VALID_TYPES = %w(resource supplier)

  attr_reader :type,
              :id

  def initialize(type, id)
    @type = type.to_s
    @id = id
  end

  def key
    "#{type}_#{id}"
  end

  def perform(url, headers: {})
    return nil unless VALID_TYPES.include?(type)

    begin
      response = Excon.get(url, headers: headers)
    rescue Excon::Error::Socket, Excon::Error::Timeout => e
      response = nil
    end

    if response && response.status == 200
      expire_error

      begin
        data = JSON.parse(response.body).deep_symbolize_keys
      rescue JSON::ParserError
        return nil
      end

      data
    else
      create_error(url)
      nil
    end
  end

  def current_error(query_only: false)
    @current_error ||= begin
      query = PluginStoreRow.where(plugin_name: namespace)
      query = query.where("(value::json->>'id')::integer = ?", id)
      query = query.where("(value::json->>'type') = ?", type)
      query = query.where("(value::json->>'expired_at') IS NULL")

      return nil if !query.exists?
      return query if query_only

      JSON.parse(query.first.value).symbolize_keys
    end
  end

  def self.current_error(type, id)
    new(type, id).current_error
  end

  def limit
    self.send("#{@type}_limit")
  end

  private

  def create_error(url)
    if attrs = current_error
      attrs[:updated_at] = Time.now
      attrs[:count] = attrs[:count].to_i + 1
    else
      attrs = {
        id: id,
        type: type,
        message: I18n.t("subscription_client.notices.connection_error", url: url),
        created_at: Time.now,
        count: 1
      }
    end

    PluginStore.set(namespace, key, attrs)

    @current_error = nil

    if reached_limit?
      SubscriptionClientNotice.notify_connection_error(type, id, url)
    end
  end

  def expire_error
    if query = current_error(query_only: true)
      record = query.first
      error = JSON.parse(record.value)
      error['expired_at'] = Time.now
      record.value = error.to_json
      record.save
    end

    SubscriptionClientNotice.expire_connection_error(type, id)
  end

  def supplier_limit
    SUPPLIER_ERROR_LIMIT
  end

  def resource_limit
    RESOURCE_ERROR_LIMIT
  end

  def reached_limit?
    return false unless current_error.present?
    current_error[:count].to_i >= limit
  end

  def namespace
    "#{SubscriptionClient::PLUGIN_NAME}_connection_error"
  end
end
