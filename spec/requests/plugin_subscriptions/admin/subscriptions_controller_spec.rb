# frozen_string_literal: true
require_relative '../../../plugin_helper'

describe PluginSubscriptions::AdminSubscriptionsController do
  fab!(:admin_user) { Fabricate(:user, admin: true) }
  fab!(:plugin_subscription) { Fabricate(:plugin_subscription) }

  def generate_payload(request_id, user_id)
    uri = URI(@subscription.authentication_url(user_id, request_id))
    keys = @subscription.authentication.get_keys(request_id)
    raw_payload = {
      key: "12345",
      nonce: keys.nonce,
      push: false,
      api: UserApiKeysController::AUTH_API_VERSION
    }.to_json
    public_key = OpenSSL::PKey::RSA.new(keys.pem)
    Base64.encode64(public_key.public_encrypt(raw_payload))
  end

  before do
    @subscription = PluginSubscriptions::Subscriptions.new
    sign_in(admin_user)
  end

  it "#index" do
    get "/admin/plugins/plugin-subs/subscriptions.json"
    expect(response.parsed_body['server']).to eq(@subscription.server)
    expect(response.parsed_body['authentication'].deep_symbolize_keys).to eq(PluginSubscriptions::AuthenticationSerializer.new(@subscription.authentication, root: false).as_json)
    expect(response.parsed_body['subscriptions']).to eq(ActiveModel::ArraySerializer.new(@subscription.subscriptions, each_serializer: PluginSubscriptions::SubscriptionSerializer).as_json)
  end

  it "#authorize" do
    get "/admin/plugins/plugin-subs/authorize"
    expect(response.status).to eq(302)
    expect(cookies[:user_api_request_id].present?).to eq(true)
  end

  it "#destroy_authentication" do
    request_id = SecureRandom.hex(32)
    payload = generate_payload(request_id, admin_user.id)
    @subscription.authentication_response(request_id, payload)

    delete "/admin/plugins/plugin-subs/authorize.json"

    expect(response.status).to eq(200)
    expect(PluginSubscriptions::Subscriptions.authorized?).to eq(false)
  end

  context "subscription" do
    before do
      stub_subscription_request(200, valid_subscription)
    end

    it "handles authentication response" do
      request_id = cookies[:user_api_request_id] = SecureRandom.hex(32)
      payload = generate_payload(request_id, admin_user.id)

      get "/admin/plugins/plugin-subs/authorize/callback", params: { payload: payload }

      expect(response).to redirect_to("/admin/plugins/plugin-subs/subscriptions")
    end

    it "updates the subscriptions" do
      stub_subscription_request(200, valid_subscription)

      plugin_subscription.active = false
      plugin_subscription.save!

      post "/admin/plugins/plugin-subs/subscriptions.json"

      expect(response.status).to eq(200)
      expect(PluginSubscription.exists?(product_id: valid_subscription[:product_id])).to eq(true)
    end
  end
end
