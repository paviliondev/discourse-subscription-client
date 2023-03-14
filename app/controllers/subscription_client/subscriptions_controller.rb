# frozen_string_literal: true

class SubscriptionClient::SubscriptionsController < SubscriptionClient::AdminController
  def index
    render_serialized(SubscriptionClientSubscription.all, ::SubscriptionClientSubscriptionSerializer, root: 'subscriptions')
  end

  def update
    result = SubscriptionClient::Subscriptions.update

    if result.errors.blank?
      render_serialized(SubscriptionClientSubscription.all, ::SubscriptionClientSubscriptionSerializer, root: 'subscriptions')
    else
      render json: failed_json.merge(errors: result.errors)
    end
  end
end
