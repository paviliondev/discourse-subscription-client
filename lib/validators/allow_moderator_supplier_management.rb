# frozen_string_literal: true

class AllowModeratorSupplierManagementValidator
  def initialize(opts = {})
    @opts = opts
  end

  def valid_value?(val)
    return true if val == "f"
    SiteSetting.subscription_client_allow_moderator_subscription_management
  end

  def error_message
    I18n.t("site_settings.errors.allow_moderator_subscription_management_not_enabled")
  end
end
