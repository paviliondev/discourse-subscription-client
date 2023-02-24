# frozen_string_literal: true
# name: discourse-subscription-client
# about: Subscription client
# version: 0.1.2
# authors: Robert Barrow, Angus McLeod
# url: https://github.com/paviliondev/discourse-subscription-client.git
# contact_emails: development@pavilion.tech

register_asset 'stylesheets/common/common.scss'
register_svg_icon "far-building"
add_admin_route "admin.subscription_client.title", "subscriptionClient"

gem "discourse_subscription_client", "0.1.0.pre9", require_name: "discourse_subscription_client"
