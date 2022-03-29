# frozen_string_literal: true

class SubscriptionClient::AdminController < Admin::AdminController
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
end
