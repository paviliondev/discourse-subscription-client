# frozen_string_literal: true

class SubscriptionClient::NoAccessController < ApplicationController
  def index
    head :ok
  end
end
