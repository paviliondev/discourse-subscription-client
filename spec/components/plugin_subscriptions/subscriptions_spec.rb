# frozen_string_literal: true

require_relative '../../plugin_helper'

describe PluginSubscriptions::Subscriptions do
  fab!(:user) { Fabricate(:user) }
  fab!(:valid_subscription) { Fabricate(:plugin_subscription) }
  fab!(:invalid_subscription) { Fabricate(:plugin_subscription, active: false) }

  it "initializes subscription authentication and subscription" do
    subscriptions = described_class.new
    expect(subscriptions.authentication.class).to eq(PluginSubscriptions::Authentication)
    expect(subscriptions.subscriptions).to eq(PluginSubscription.all)
  end

  it "returns authorized state" do
    subscriptions = described_class.new
    expect(subscriptions.authorized?).to eq(false)
  end

  context "subscriptions" do
    before do
      @subscriptions = described_class.new
    end

    it "updates subscriptions" do
      stub_subscription_request(200, valid_subscription.as_json)
      expect(@subscriptions.update).to eq(true)

      subscription = PluginSubscription.find_by(product_id: valid_subscription.product_id)
      expect(subscription.present?).to eq(true)
      expect(subscription.active).to eq(true)
    end

    it "handles invalid subscriptions" do
      stub_subscription_request(200, invalid_subscription.as_json)
      expect(@subscriptions.update).to eq(false)
      subscription = PluginSubscription.find_by(product_id: invalid_subscription.product_id)
      expect(subscription.present?).to eq(true)
      expect(subscription.active).to eq(false)
    end

    it "handles subscription http errors" do
      stub_subscription_request(404, {})
      expect(@subscriptions.update).to eq(false)
      expect(PluginSubscription.exists?(product_id: invalid_subscription.product_id)).to eq(false)
    end

    it "has class aliases" do
      stub_subscription_request(200, valid_subscription.as_json)
      expect(described_class.update).to eq(true)
    end
  end

  context "authentication" do
    before do
      @subscriptions = described_class.new
      user.update!(admin: true)
    end

    it "generates a valid authentication request url" do
      request_id = SecureRandom.hex(32)
      uri = URI(@subscriptions.authentication_url(user.id, request_id))
      expect(uri.host).to eq(@subscriptions.server)

      parsed_query = Rack::Utils.parse_query uri.query
      expect(parsed_query['public_key'].present?).to eq(true)
      expect(parsed_query['nonce'].present?).to eq(true)
      expect(parsed_query['client_id'].present?).to eq(true)
      expect(parsed_query['auth_redirect'].present?).to eq(true)
      expect(parsed_query['application_name']).to eq(SiteSetting.title)
      expect(parsed_query['scopes']).to eq(@subscriptions.scope)
    end

    def generate_payload(request_id, user_id)
      uri = URI(@subscriptions.authentication_url(user_id, request_id))
      keys = @subscriptions.authentication.get_keys(request_id)
      raw_payload = {
        key: "12345",
        nonce: keys.nonce,
        push: false,
        api: UserApiKeysController::AUTH_API_VERSION
      }.to_json
      public_key = OpenSSL::PKey::RSA.new(keys.pem)
      Base64.encode64(public_key.public_encrypt(raw_payload))
    end

    it "handles authentication response if request and response is valid" do
      request_id = SecureRandom.hex(32)
      payload = generate_payload(request_id, user.id)

      expect(@subscriptions.authentication_response(request_id, payload)).to eq(true)
      expect(@subscriptions.authorized?).to eq(true)
    end

    it "discards authentication response if user who made request as not an admin" do
      user.update!(admin: false)

      request_id = SecureRandom.hex(32)
      payload = generate_payload(request_id, user.id)

      expect(@subscriptions.authentication_response(request_id, payload)).to eq(false)
      expect(@subscriptions.authorized?).to eq(false)
    end

    it "discards authentication response if request_id is invalid" do
      payload = generate_payload(SecureRandom.hex(32), user.id)

      expect(@subscriptions.authentication_response(SecureRandom.hex(32), payload)).to eq(false)
      expect(@subscriptions.authorized?).to eq(false)
    end

    it "destroys authentication" do
      request_id = SecureRandom.hex(32)
      payload = generate_payload(request_id, user.id)
      @subscriptions.authentication_response(request_id, payload)

      expect(@subscriptions.destroy_authentication).to eq(true)
      expect(@subscriptions.authorized?).to eq(false)
    end
  end
end
