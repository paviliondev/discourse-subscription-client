# frozen_string_literal: true

class SubscriptionClient::AdminController < Admin::AdminController
  before_action :ensure_admin

  def index
    render_json_dump(
      active_notice_count: SubscriptionClientNotice.list.count,
      featured_notices: serialize_data(featured_notices, SubscriptionClientNoticeSerializer)
    )
  end

  protected

  def featured_notices
    @featured_notices ||= begin
      SubscriptionClientNotice.list(
        notice_type: SubscriptionClientNotice.types[:info],
        notice_subject_type: SubscriptionClientNotice.notice_subject_types[:supplier]
      )
    end
  end
end
