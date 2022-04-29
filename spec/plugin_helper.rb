# frozen_string_literal: true
def authenticate_subscription
  SubscriptionClient::Authentication.any_instance.stubs(:active).returns(true)
end

def valid_subscription
  {
    product_id: "prod_CBTNpi3fqWWkq0",
    price_id: "price_id",
    price_name: "business"
  }
end

def invalid_subscription
  {
    product_id: "prod_CBTNpi3fqWWkq0",
    price_id: "price_id"
  }
end

def stub_subscription_request(status, resource, response)
  url = resource.supplier.url
  stub_request(:get, "#{url}/subscription-server/user-subscriptions?resources[]=#{resource.name}").to_return(status: status, body: { subscriptions: [response] }.to_json)
end

def stub_server_request(server_url, supplier, status = 200)
  stub_request(:get, "#{server_url}/subscription-server").to_return(status: status, body: { supplier: supplier }.to_json)
end

def stub_subscription_messages_request(supplier, status, messages)
  stub_request(:get, "#{supplier.url}/subscription-server/messages").to_return(status: status, body: { messages: messages }.to_json)
end

def stub_plugin_status_request(status, response)
  stub_request(:get, SubscriptionClient.plugin_status_server_url).to_return(status: status, body: response.to_json)
end

def raw_auth_payload(request_id)
  keys = SubscriptionClient::Authorization.get_keys(request_id)
  {
    key: "12345",
    nonce: keys.nonce,
    push: false,
    api: UserApiKeysController::AUTH_API_VERSION
  }
end

def generate_auth_payload(user_id, request_id)
  result = SubscriptionClient::Authorization.generate_keys(user_id, request_id)
  keys = SubscriptionClient::Authorization.get_keys(request_id)
  public_key = OpenSSL::PKey::RSA.new(keys.pem)
  Base64.encode64(public_key.public_encrypt(raw_auth_payload(request_id).to_json))
end
