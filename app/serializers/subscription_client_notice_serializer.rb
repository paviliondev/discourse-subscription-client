# frozen_string_literal: true

class SubscriptionClientNoticeSerializer < ApplicationSerializer
  attributes :id,
             :title,
             :message,
             :notice_type,
             :notice_subject_type,
             :notice_subject_id,
             :created_at,
             :expired_at,
             :updated_at,
             :dismissed_at,
             :retrieved_at,
             :hidden_at,
             :dismissable,
             :can_hide

  def dismissable
    object.dismissable?
  end

  def can_hide
    object.can_hide?
  end

  def notice_type
    SubscriptionClientNotice.types.key(object.notice_type)
  end

  def messsage
    PrettyText.cook(object.message)
  end
end
