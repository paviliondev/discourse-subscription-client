# frozen_string_literal: true
Fabricator(:subscription_client_user_api_key, from: :user_api_key) do
  scopes { [Fabricate.build(:user_api_key_scope, name: 'discourse-subscription-server:user_subscription')] }
end
