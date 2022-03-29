# frozen_string_literal: true

class SubscriptionClient::AdminController < Admin::AdminController
  def index
    render_json_dump(
      authorized_supplier_count: SubscriptionClientSupplier.authorized.count,
      resource_count: SubscriptionClientResource.count
    )
  end
end
