def authenticate_subscription
  PluginSubscriptions::Authentication.any_instance.stubs(:active?).returns(true)
end

def valid_subscription
  {
    product_id: "prod_CBTNpi3fqWWkq0",
    price_id: "price_id",
    price_nickname: "business"
  }
end

def invalid_subscription
  {
    product_id: "prod_CBTNpi3fqWWkq0",
    price_id: "price_id"
  }
end

def stub_subscription_request(status, subscription)
  authenticate_subscription
  subs = PluginSubscriptions::Subscriptions.new
  stub_request(:get, "https://#{subs.server}/subscription-server/user-subscriptions/#{subs.subscription_type}/#{subs.client_name}").to_return(status: status, body: { subscriptions: [subscription] }.to_json)
end
