import { withPluginApi } from "discourse/lib/plugin-api";
import { isPresent } from "@ember/utils";
import { observes } from "discourse-common/utils/decorators";
import User from "discourse/models/user";
import I18n from "I18n";
import { h } from "virtual-dom";

export default {
  name: "subscription-client",
  after: "message-bus",
  initialize(container) {
    const user = container.lookup("service:current-user");
    const siteSettings = container.lookup("service:site-settings");

    if (
      !siteSettings.subscription_client_enabled ||
      !user ||
      !user.can_manage_subscriptions
    ) {
      return;
    }

    const bus = container.lookup("message-bus:main");

    bus.subscribe("/subscription_client_user", (data) => {
      if (isPresent(data.visible_notice_count)) {
        user.set("subscription_notice_count", data.visible_notice_count);
      }
    });

    const allowModSupplierAuth =
      siteSettings.subscription_client_allow_moderator_supplier_management;
    const canAccessSubscriptionSuppliers =
      user.admin || (user.moderator && allowModSupplierAuth);
    User.currentProp(
      "canAccessSubscriptionSuppliers",
      canAccessSubscriptionSuppliers
    );

    let subscriptionNoticeBadge = function () {
      if (user && user.subscription_notice_count) {
        return h(
          "div.badge-notification.subscription-notice",
          {
            attributes: {
              title: I18n.t(
                "admin.subscription_client.notifications.subscription_notice_count"
              ),
            },
          },
          user.subscription_notice_count
        );
      }
    };

    withPluginApi("0.8.32", (api) => {
      api.reopenWidget("header-dropdown", {
        html(attrs) {
          if (
            attrs.title === "hamburger_menu" &&
            user.can_manage_subscriptions
          ) {
            let coreContents = attrs.contents;
            attrs.contents = function () {
              return [
                coreContents.apply(this, arguments),
                subscriptionNoticeBadge.apply(this, arguments),
              ];
            };
            return this._super(attrs);
          } else {
            return this._super(attrs);
          }
        },
      });

      api.decorateWidget("hamburger-menu:generalLinks", () => {
        return [
          {
            route: "adminPlugins.subscriptionClient.subscriptions",
            className: "subscription-notices",
            label: "admin.subscription_client.title",
            badgeCount: "subscription_notice_count",
            badgeClass: "subscription-notice",
          },
        ];
      });

      api.modifyClass("component:site-header", {
        pluginId: "subscription-client",

        @observes("currentUser.subscription_notice_count")
        subscriptionClientNoticeCountChanged() {
          this.queueRerender();
        },
      });
    });
  },
};
