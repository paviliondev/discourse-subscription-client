# frozen_string_literal: true

class PluginSubscriptions::AdminSubscriptionsController < PluginSubscriptions::AdminController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, only: [:authorize, :authorize_callback]

  def index
    render_serialized(subscriptions, PluginSubscriptions::SubscriptionPageSerializer, root: false)
    # subscriptions = PluginSubscription.all

    # render_json_dump(
    #   subscriptions: ActiveModel::ArraySerializer.new(subscriptions, each_serializer: PluginSubscriptions::SubscriptionSerializer),
    # )
  end

  def authorize
    request_id = SecureRandom.hex(32)
    cookies[:user_api_request_id] = request_id
    redirect_to subscriptions.authentication_url(current_user.id, request_id).to_s
  end

  def authorize_callback
    payload = params[:payload]
    request_id = cookies[:user_api_request_id]

    subscriptions.authentication_response(request_id, payload)
    subscriptions.update

    redirect_to '/admin/plugins/plugin-subs/subscriptions'
  end

  def destroy_authentication
    if subscriptions.destroy_authentication
      render json: success_json
    else
      render json: failed_json
    end
  end

  def update_subscriptions
    if subscriptions.update
      render_serialized(subscriptions, PluginSubscriptions::SubscriptionPageSerializer, root: false)
      # serialized_subscriptions = PluginSubscriptions::SubscriptionSerializer.new(subscription.subscription, root: false)
      # render_json_dump(
      #   subscriptions: ActiveModel::ArraySerializer.new(subscriptions, each_serializer: PluginSubscriptions::SubscriptionSerializer),
      # )
    else
      render json: failed_json
    end
  end

  protected

  def subscriptions
    @subscriptions ||= PluginSubscriptions::Subscriptions.new
  end
end
