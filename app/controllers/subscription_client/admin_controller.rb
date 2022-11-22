# frozen_string_literal: true

class SubscriptionClient::AdminController < ApplicationController
  requires_login
  before_action :ensure_can_manage_subscriptions

  def index
    respond_to do |format|
      format.html do
        render :index
      end
      format.json do
        render_json_dump(
          authorized_supplier_count: SubscriptionClientSupplier.authorized.count,
          resource_count: SubscriptionClientResource.count
        )
      end
    end
  end

  def ensure_can_manage_subscriptions
    Guardian.new(current_user).ensure_can_manage_subscriptions!
  end
end
