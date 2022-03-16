# frozen_string_literal: true

class PluginSubscriptions::Subscriptions
  include ActiveModel::Serialization

  REQUIRED_KEYS ||= %w(
    product_id
    product_name
    price_id
    price_nickname
  )
  OPTIONAL_KEYS ||= %w(
    supplier_name
  )
  KEYS ||= REQUIRED_KEYS + OPTIONAL_KEYS

  attr_accessor :authentication,
                :subscriptions

  def initialize
    @authentication = PluginSubscriptions::Authentication.new(get_authentication)
    @subscriptions = PluginSubscription.all
  end

  def authorized?
    @authentication.active?
  end

  def server
    "test.thepavilion.io"
  end

  def subscription_type
    "stripe"
  end

  def client_name
    "plugin-subscriptions"
  end

  def scope
    "discourse-subscription-server:user_subscription"
  end

  def update
    if @authentication.active?
      response = Excon.get(
        "https://#{server}/subscription-server/user-subscriptions/#{subscription_type}",
        headers: {
          "User-Api-Key" => @authentication.api_key
        }
      )

      if response.status == 200
        begin
          data = JSON.parse(response.body).deep_symbolize_keys
        rescue JSON::ParserError
          return false
        end

        return false unless data && data.is_a?(Hash)
        subscriptions = data[:subscriptions]

        PluginSubscription.invalidate_all

        @result = PluginSubscriptions::SubscriptionsRetrieveResults.new

        subscriptions.each do |entry|
          entry = validate_item_hash(entry)
          next unless entry

          create_result = false
          begin
            create_result = PluginSubscription.create!(entry)
            PluginSubscription.activate!(entry[:product_id], entry[:price_id])
          rescue ActiveRecord::RecordInvalid
            dupe_record = true
            PluginSubscription.activate!(entry[:product_id], entry[:price_id])
          end

          if create_result || dupe_record
            @result.success += 1
          else
            @result.failed_to_create += 1
          end

          @result.duplicate += 1 if dupe_record
        end

        return @result.success > 0
      end
    end

    false
  end

  def validate_item_hash(item)
    item = item.delete_if { |k, v| v.empty? }
    identifier = find_first_required_value(item)

    if REQUIRED_KEYS.any? { |key| !item.has_key?(key.to_sym) }
      add_to_result(:missing_required, identifier)
      return false
    end

    item
  end

  def add_to_result(key, identifier)
    @result.send("#{key}=", @result.send(key) + 1)

    if identifier.present?
      items = @result.send(:"#{key}_items")
      items.push(identifier)
      @result.send(:"#{key}_items=", items)
    end
  end

  def find_first_required_value(item)
    value = nil

    REQUIRED_KEYS.each do |key|
      if item[key.to_sym].present?
        value = item[key.to_sym]
        break
      end
    end

    value
  end

  def authentication_url(user_id, request_id)
    keys = @authentication.generate_keys(user_id, request_id)
    params = {
      public_key: keys.public_key,
      nonce: keys.nonce,
      client_id: @authentication.client_id,
      auth_redirect: "#{Discourse.base_url}/admin/plugins/plugin-subs/authorize/callback",
      application_name: SiteSetting.title,
      scopes: scope
    }

    uri = URI.parse("https://#{server}/user-api-key/new")
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def authentication_response(request_id, payload)
    data = @authentication.decrypt_payload(request_id, payload)
    return false unless data.is_a?(Hash) && data[:key] && data[:user_id]

    api_key = data[:key]
    user_id = data[:user_id]
    user = User.find(user_id)

    if user&.admin
      @authentication = set_authentication(api_key, user.id)
      true
    else
      false
    end
  end

  def destroy_authentication
    if remove_authentication
      @authentication = PluginSubscriptions::Authentication.new(get_authentication)
      !@authentication.active?
    else
      false
    end
  end

  def self.authorized?
    self.new.authorized?
  end

  def self.update
    self.new.update
  end

  def self.namespace
    PluginSubscriptions::PLUGIN_NAME
  end

  private

  def authentication_db_key
    "authentication"
  end

  def get_authentication
    raw = PluginStore.get(self.class.namespace, authentication_db_key)
    OpenStruct.new(
      key: raw && raw['key'],
      auth_by: raw && raw['auth_by'],
      auth_at: raw && raw['auth_at']
    )
  end

  def set_authentication(key, user_id)
    PluginStore.set(self.class.namespace, authentication_db_key,
      key: key,
      auth_by: user_id,
      auth_at: Time.now
    )
    PluginSubscriptions::Authentication.new(get_authentication)
  end

  def remove_authentication
    PluginStore.remove(self.class.namespace, authentication_db_key)
    get_authentication
  end
end
