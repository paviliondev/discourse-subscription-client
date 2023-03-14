import Controller, { inject as controller } from "@ember/controller";
import SubscriptionClientSubscription from "../models/subscription-client-subscription";
import { alias, notEmpty } from "@ember/object/computed";
import { observes, on } from "discourse-common/utils/decorators";

export default Controller.extend({
  adminPluginsSubscriptionClient: controller(),
  authorizedSupplierCount: alias(
    "adminPluginsSubscriptionClient.authorizedSupplierCount"
  ),
  resourceCount: alias("adminPluginsSubscriptionClient.resourceCount"),
  classNameBindings: [":subscription", "subscription.active:active:inactive"],
  hasSubscriptions: notEmpty("subscriptions"),
  messageKey: "info",
  messageClass: "info",

  @on("init")
  @observes("authorizedSupplierCount", "currentUser.can_manage_suppliers")
  changeMessageKey() {
    if (this.resourceCount === 0) {
      this.set("messageKey", "no_resources");
    } else if (this.authorizedSupplierCount === 0) {
      let key = this.currentUser.can_manage_suppliers
        ? "no_authorized_suppliers"
        : "no_authorized_suppliers_no_access";
      this.set("messageKey", key);
    } else {
      this.set("messageKey", "info");
    }
  },

  actions: {
    update() {
      this.set("updating", true);
      SubscriptionClientSubscription.update()
        .then((result) => {
          if (result.subscriptions && result.subscriptions.length > 0) {
            this.setProperties({
              updateIcon: "check",
              subscriptions: result.subscriptions,
            });
          } else {
            this.set("updateIcon", "times");
          }
        })
        .finally(() => {
          this.set("updating", false);
          setTimeout(() => {
            this.set("updateIcon", null);
          }, 7000);
        });
    },
  },
});
