# frozen_string_literal: true

SubscriptionClient::Engine.routes.draw do
  get '' => 'admin#index', defaults: { format: 'json' }

  get 'suppliers' => 'suppliers#index'
  get 'suppliers/authorize' => 'suppliers#authorize'
  get 'suppliers/authorize/callback' => 'suppliers#authorize_callback'
  delete 'suppliers/authorize' => 'suppliers#destroy'

  get 'subscriptions' => 'subscriptions#index', defaults: { format: 'json' }
  post 'subscriptions' => 'subscriptions#update', defaults: { format: 'json' }

  get 'notices' => 'notices#index'
  put 'notices/:notice_id/dismiss' => 'notices#dismiss'
  put 'notices/:notice_id/hide' => 'notices#hide'
  put 'notices/dismiss' => 'notices#dismiss_all'
end

Discourse::Application.routes.append do
  mount ::SubscriptionClient::Engine, at: "/admin/plugins/subscription-client"
end
