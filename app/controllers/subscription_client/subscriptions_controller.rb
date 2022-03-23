# frozen_string_literal: true

class SubscriptionClient::SubscriptionsController < SubscriptionClient::AdminController
  def index
    render_serialized(SubscriptionClientSubscription.all, ::SubscriptionClientSubscriptionSerializer, root: false)
  end

  def update
    if SubscriptionClient::Subscriptions.update
      render_serialized(SubscriptionClientSubscription.all, ::SubscriptionClientSubscriptionSerializer, root: false)
    else
      render json: failed_json
    end
  end
end
