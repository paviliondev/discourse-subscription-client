# frozen_string_literal: true

class SubscriptionClient::NoticesController < SubscriptionClient::AdminController
  before_action :find_notice, only: [:dismiss, :hide, :show]

  def index
    notice_type = params[:notice_type]
    notice_subject_type = params[:notice_subject_type]
    page = params[:page].to_i

    visible = ActiveRecord::Type::Boolean.new.cast(params[:visible])

    if current_user.admin
      include_all = ActiveRecord::Type::Boolean.new.cast(params[:include_all])
    else
      include_all = false
    end

    if notice_type
      if notice_type.is_a?(Array)
        notice_type = notice_type.map { |t| SubscriptionClientNotice.types[t.to_sym] }
      else
        notice_type = SubscriptionClientNotice.types[notice_type.to_sym]
      end
    end

    if notice_subject_type
      if notice_subject_type.is_a?(Array)
        notice_subject_type = notice_subject_type.map { |t| SubscriptionClientNotice.notice_subject_types[t.to_sym] }
      else
        notice_subject_type = SubscriptionClientNotice.notice_subject_types[notice_subject_type.to_sym]
      end
    end

    notices = SubscriptionClientNotice.list(
      include_all: include_all,
      page: page,
      notice_type: notice_type,
      notice_subject_type: notice_subject_type,
      visible: visible
    )

    render_json_dump(
      notices: serialize_data(notices, SubscriptionClientNoticeSerializer),
      hidden_notice_count: SubscriptionClientNotice.hidden.count
    )
  end

  def dismiss
    if @notice.dismissable? && @notice.dismiss!
      render json: success_json.merge(dismissed_at: @notice.dismissed_at)
    else
      render json: failed_json
    end
  end

  def show
    if @notice.hidden? && @notice.show!
      render json: success_json
    else
      render json: failed_json
    end
  end

  def hide
    if @notice.can_hide? && @notice.hide!
      render json: success_json.merge(hidden_at: @notice.hidden_at)
    else
      render json: failed_json
    end
  end

  private

  def find_notice
    params.require(:notice_id)
    @notice = SubscriptionClientNotice.find(params[:notice_id])
    raise Discourse::InvalidParameters.new(:notice_id) unless @notice
  end
end
