# frozen_string_literal: true

class SubscriptionClient::AdminController < ::Admin::AdminController
  before_action :ensure_admin

  def index
    render_json_dump(
      server: SubscriptionClient.server,
      authentication: serialize_data(authentication, SubscriptionClient::AuthenticationSerializer, roote: false),
      active_notice_count: SubscriptionClientNotice.list.count,
      featured_notices: serialize_data(featured_notices, SubscriptionClientNoticeSerializer)
    )
  end

  protected

  def authentication
    @authentication ||= SubscriptionClient::Authentication.get
  end

  def featured_notices
    @featured_notices ||= begin
      SubscriptionClientNotice.list(
        notice_type: SubscriptionClientNotice.types[:info],
        notice_subject_type: SubscriptionClientNotice.notice_subject_types[:supplier]
      )
    end
  end
end
