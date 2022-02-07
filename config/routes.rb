# frozen_string_literal: true
Discourse::Application.routes.append do
  post 'admin/plugins/plugin-subs/authorization/callback' => "plugin_subscriptions/authorization#callback"

  scope module: 'plugin_subscriptions', constraints: AdminConstraint.new do
    get 'admin/plugins/plugin-subs' => 'admin#index'

    get 'admin/plugins/plugin-subs/subscriptions' => 'admin_subscriptions#index'
    post 'admin/plugins/plugin-subs/subscriptions' => 'admin_subscriptions#update_subscriptions'
    get 'admin/plugins/plugin-subs/authorize' => 'admin_subscriptions#authorize'
    get 'admin/plugins/plugin-subs/authorize/callback' => 'admin_subscriptions#authorize_callback'
    delete 'admin/plugins/plugin-subs/authorize' => 'admin_subscriptions#destroy_authentication'

    get 'admin/plugins/plugin-subs/notice' => 'admin_notice#index'
    put 'admin/plugins/plugin-subs/notice/:notice_id/dismiss' => 'admin_notice#dismiss'
    put 'admin/plugins/plugin-subs/notice/:notice_id/hide' => 'admin_notice#hide'
    put 'admin/plugins/plugin-subs/notice/dismiss' => 'admin_notice#dismiss_all'
    get 'admin/plugins/plugin-subs/notices' => 'admin_notice#index'
  end
end
