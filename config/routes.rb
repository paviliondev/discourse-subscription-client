# frozen_string_literal: true

SubscriptionClient::Engine.routes.draw do
  get '' => 'admin#index'

  get 'authorize' => 'authorization#authorize'
  get 'authorize/callback' => 'authorization#authorize_callback'
  delete 'authorize' => 'authorization#destroy'

  get 'subscriptions' => 'subscriptions#index'
  post 'subscriptions' => 'subscriptions#update'

  get 'notices' => 'notices#index'
  put 'notices/:notice_id/dismiss' => 'notices#dismiss'
  put 'notices/:notice_id/hide' => 'notices#hide'
  put 'notices/dismiss' => 'notices#dismiss_all'
end

Discourse::Application.routes.append do
  mount ::SubscriptionClient::Engine, at: "/admin/plugins/subscription-client"
end
