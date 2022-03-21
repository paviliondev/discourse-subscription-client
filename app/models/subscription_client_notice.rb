# frozen_string_literal: true

class SubscriptionClientNotice < ActiveRecord::Base
  belongs_to :notice_subject, polymorphic: true
  delegate :name, to: :subject

  scope :warnings, -> { where(notice_type: SubscriptionClientNotice.types[:warning]) }

  def notice_subject_type=(class_name)
    super(class_name.constantize.base_class.to_s)
  end

  def self.types
    @types ||= Enum.new(
      info: 0,
      warning: 1,
      connection_error: 2
    )
  end

  def self.notice_subject_types
    @notice_subject_types ||= {
      resource: "SubscriptionClientResource",
      supplier: "SubscriptionClientSupplier"
    }
  end

  def dismiss!
    if dismissable?
      self.dismissed_at = DateTime.now.iso8601(3)
      self.save_and_publish
    end
  end

  def hide!
    if can_hide?
      self.hidden_at = DateTime.now.iso8601(3)
      self.save_and_publish
    else
      false
    end
  end

  def expire!
    if !expired?
      self.expired_at = DateTime.now.iso8601(3)
      self.save_and_publish
    else
      false
    end
  end

  def save_and_publish
    if self.save
      self.class.publish_notice_count
    else
      false
    end
  end

  def can_hide?
    !hidden? && (
      notice_type === self.class.types[:connection_error] ||
      notice_type === self.class.types[:warning]
    ) && (
      notice_subject_type === self.class.notice_subject_types[:resource]
    )
  end

  def expired?
    expired_at.present?
  end

  def dismissed?
    dismissed_at.present?
  end

  def dismissable?
    !expired? && !dismissed? && notice_type === self.class.types[:info]
  end

  def hidden?
    hidden_at.present?
  end

  def self.publish_notice_count
    payload = { active_notice_count: list.count }
    MessageBus.publish("/subscription-client/notices", payload, group_ids: [Group::AUTO_GROUPS[:admins]])
  end

  def self.list(notice_type: nil, notice_subject_type: nil, notice_subject_id: nil, title: nil, include_all: false, visible: false, page: nil, page_limit: 30)
    query = SubscriptionClientNotice.all
    query = query.where("hidden_at IS NULL") if visible
    query = query.where("dismissed_at IS NULL") unless include_all
    query = query.where("expired_at IS NULL") unless include_all
    query = query.where("notice_subject_type = ?", notice_subject_type.to_s) if notice_subject_type
    query = query.where("notice_subject_id = ?", notice_subject_id.to_i) if notice_subject_id
    if notice_type
      type_query_str = notice_type.is_a?(Array) ? "notice_type IN (?)" : "notice_type = ?"
      query = query.where(type_query_str, notice_type)
    end
    query = query.where("title = ?", title) if title
    query = query.limit(page_limit).offset(page.to_i * page_limit) if !page.nil?
    query.order("expired_at DESC, updated_at DESC, dismissed_at DESC, created_at DESC")
  end

  def self.notify_connection_error(notice_subject_type, notice_subject_id, url)
    notices = list(
      notice_type: types[:connection_error],
      notice_subject_type: notice_subject_types[notice_subject_type.to_sym],
      notice_subject_id: notice_subject_id
    )

    if notices.any?
      notice = notices.first
      notice.updated_at = DateTime.now.iso8601(3)
      notice.save
    else
      create!(
        title: I18n.t("subscription_client.notices.#{notice_subject_type.to_s}.connection_error.title"),
        message: I18n.t("subscription_client.notices.#{notice_subject_type.to_s}.connection_error.message", url: url),
        notice_subject_type: notice_subject_types[notice_subject_type.to_sym],
        notice_subject_id: notice_subject_id,
        notice_type: types[:connection_error],
        created_at: DateTime.now.iso8601(3),
        updated_at: DateTime.now.iso8601(3)
      )
    end
  end

  def self.expire_connection_error(notice_subject_type_key, notice_subject_id)
    expire_all(types[:connection_error], notice_subject_types[notice_subject_type_key.to_sym], notice_subject_id)
  end

  def self.dismiss_all
    dismissed_count = self.where("
      notice_type = #{types[:info]} AND
      expired_at IS NULL AND
      dismissed_at IS NULL
    ").update_all("dismissed_at = now()")
    publish_notice_count if dismissed_count.to_i > 0
    dismissed_count
  end

  def self.expire_all(notice_type, notice_subject_type, notice_subject_id)
    expired_count = self.where("
      notice_type = #{notice_type} AND
      notice_subject_type = '#{notice_subject_type}' AND
      notice_subject_id = #{notice_subject_id} AND
      expired_at IS NULL
    ").update_all("expired_at = now()")
    publish_notice_count if expired_count.to_i > 0
    expired_count
  end
end

# == Schema Information
#
# Table name: subscription_client_notices
#
#  id                  :bigint           not null, primary key
#  title               :string           not null
#  message             :string
#  notice_type         :integer          not null
#  notice_subject_type :string
#  notice_subject_id   :bigint
#  changed_at          :datetime
#  retrieved_at        :datetime
#  dismissed_at        :datetime
#  expired_at          :datetime
#  hidden_at           :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_subscription_client_notices_on_notice_subject  (notice_subject_type,notice_subject_id)
#  sc_unique_notices                                    (notice_type,notice_subject_type,notice_subject_id,changed_at) UNIQUE
#
