# frozen_string_literal: true

class SubscriptionClient::NoticesController < SubscriptionClient::AdminController
  before_action :find_notice, only: [:dismiss, :hide]

  def index
    notice_type = params[:notice_type]
    notice_subject_type = params[:notice_subject_type]
    page = params[:page].to_i
    include_all = ActiveRecord::Type::Boolean.new.cast(params[:include_all])
    visible = ActiveRecord::Type::Boolean.new.cast(params[:visible])

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

    render_serialized(notices, SubscriptionClientNoticeSerializer, root: :notices)
  end

  def dismiss
    if @notice.dismissable? && @notice.dismiss!
      render json: success_json.merge(dismissed_at: @notice.dismissed_at)
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

  def dismiss_all
    if SubscriptionClientNotice.dismiss_all
      render json: success_json
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
