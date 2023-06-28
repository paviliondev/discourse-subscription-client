# frozen_string_literal: true

class SubscriptionClient::SuppliersController < SubscriptionClient::AdminController
  before_action :ensure_can_manage_suppliers
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, only: [:authorize, :authorize_callback]
  before_action :find_supplier, only: [:authorize, :destroy]

  def index
    render_serialized(SubscriptionClientSupplier.all, ::SubscriptionClientSupplierSerializer, root: "suppliers")
  end

  def authorize
    request_id = SubscriptionClient::Authorization.request_id(@supplier.id)
    cookies[:user_api_request_id] = request_id
    redirect_to SubscriptionClient::Authorization.url(current_user, @supplier, request_id).to_s, allow_other_host: true
  end

  def authorize_callback
    payload = params[:payload]
    request_id = cookies[:user_api_request_id]
    supplier_id = request_id.split('-').first

    data = SubscriptionClient::Authorization.process_response(request_id, payload)
    raise Discourse::InvalidParameters.new(:payload) unless data

    supplier = SubscriptionClientSupplier.find(supplier_id)
    raise Discourse::InvalidParameters.new(:supplier_id) unless supplier

    supplier.update(
      api_key: data[:key],
      user_id: data[:user_id],
      authorized_at: DateTime.now.iso8601(3)
    )

    SubscriptionClient::Resources.find_all

    SubscriptionClient::Subscriptions.update

    redirect_to '/admin/plugins/subscription-client/subscriptions'
  end

  def destroy
    if @supplier.destroy_authorization
      render json: success_json.merge(supplier: @supplier.reload)
    else
      render json: failed_json
    end
  end

  protected

  def find_supplier
    params.require(:supplier_id)
    @supplier = SubscriptionClientSupplier.find(params[:supplier_id])
    raise Discourse::InvalidParameters.new(:supplier_id) unless @supplier
  end

  def ensure_can_manage_suppliers
    Guardian.new(current_user).ensure_can_manage_suppliers!
  end
end
