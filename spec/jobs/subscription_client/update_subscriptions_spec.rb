# frozen_string_literal: true

RSpec.describe Jobs::SubscriptionClientUpdateSubscriptions do
  let(:result) { SubscriptionClient::Subscriptions::UpdateResult.new }

  context "when the update succeeds" do
    before do
      SubscriptionClient::Subscriptions.stubs(:update).returns(result)
    end

    it "does not enqueue retries" do
      expect_not_enqueued_with(job: :subscription_client_update_subscriptions) do
        described_class.new.execute
      end
    end
  end

  context "when the update fails not due to supplier connection" do
    before do
      result.errors["invalid_response"] = "Failed to update to supplier"
      SubscriptionClient::Subscriptions.stubs(:update).returns(result)
    end

    it "does not enqueue retries" do
      expect_not_enqueued_with(job: :subscription_client_update_subscriptions) do
        described_class.new.execute
      end
    end
  end

  context "when the update fails due to supplier connection" do
    before do
      result.errors["supplier_connection"] = "Failed to connnect to supplier"
      SubscriptionClient::Subscriptions.stubs(:update).returns(result)
    end

    it "enqueues retries" do
      freeze_time

      retry_count = described_class::MAX_RETRY_COUNT - 1
      delay = described_class::RETRY_BACKOFF * retry_count

      expect_enqueued_with(job: :subscription_client_update_subscriptions, at: delay.minutes.from_now) do
        described_class.new.execute(retry_count: retry_count)
      end
    end

    it "does not retry more than the maximum retry count" do
      expect_not_enqueued_with(job: :subscription_client_update_subscriptions) do
        described_class.new.execute(retry_count: described_class::MAX_RETRY_COUNT)
      end
    end
  end
end
