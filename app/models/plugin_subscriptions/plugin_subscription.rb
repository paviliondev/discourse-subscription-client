# frozen_string_literal: true

class PluginSubscription < ActiveRecord::Base
  validates :unique_id, presence: true, uniqueness: true
  validates :product_id, presence: true, uniqueness: { scope: :price_id }
  validates :product_name, presence: true
  validates :price_id, presence: true
  validates :price_nickname, presence: true
  validates :price_nickname_slug, presence: true
  validates :product_name_slug, presence: true

  before_validation do
    if !self.unique_id && self.product_id && self.price_id
      self.unique_id = self.product_id + self.price_id
    end

    if !self.product_name_slug && self.product_name
      self.product_name_slug = self.product_name.parameterize
    end

    if !self.price_nickname_slug && self.price_nickname
      self.price_nickname_slug = self.price_nickname.parameterize
    end
  end

  def self.destroy_all
    self.all.destroy_all
  end

  def self.invalidate_all
    self.update_all(active: false)
  end

  def self.remove!(entry)
    PluginSubscription
      .where(unique_id: entry[:unique_id])
      .destroy_all
  end

  def active?
    self.active && updated_at.to_datetime > (Time.zone.now - 2.hours).to_datetime
  end

  def self.activate!(product_id, price_id)
    PluginSubscription
      .where(product_id: product_id)
      .where(price_id: price_id)
      .first
      .update(active: true)
  end

end
