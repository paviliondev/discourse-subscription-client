# frozen_string_literal: true

module SubscriptionClient
  class Subscriptions
    class Result
      attr_accessor :supplier,
                    :resource,
                    :subscriptions

      def any?
        supplier.present? && resource.present? && subscriptions.present?
      end
    end
  end
end
