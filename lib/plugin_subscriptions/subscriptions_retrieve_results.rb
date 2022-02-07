# frozen_string_literal: true

class ::PluginSubscriptions::SubscriptionsRetrieveResults
  attr_accessor :total,
                :error,
                :missing_required_items,
                :invalid_format_items

  def initialize
    @total = 0

    self.class.types.keys.each do |key|
      self.class.class_eval { attr_accessor key }
      send("#{key.to_s}=", 0)
    end

    @missing_required_items = []
    @invalid_format_items = []
  end

  def self.types
    @types ||= Enum.new(
      success: 0,
      missing_required: 1,
      invalid_format: 2,
      duplicate: 3,
      failed_to_create: 4,
      error: 5
    )
  end

  def report
    result = {
      total: total
    }

    self.class.types.keys.each do |key|
      if (count = self.send(key)).to_i > 0
        result[key] = count
      end
    end

    [
      :missing_required_items
    ].each do |key|
      if (items = self.send(key)).any?
        result[key] = items
      end
    end

    result
  end

  def error?
    error.to_i > 0
  end
end
