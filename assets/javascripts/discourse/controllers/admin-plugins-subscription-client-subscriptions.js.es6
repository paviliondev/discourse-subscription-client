import Controller from "@ember/controller";
import SubscriptionClientSubscription from "../models/subscription-client-subscription";
import { notEmpty } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

export default Controller.extend({
  classNameBindings: [
    ":subscription",
    "subscription.active:active:inactive",
  ],
  hasSubscriptions: notEmpty("subscriptions"),
  messageUrl: "https://thepavilion.io/t/3652",
  messageKey: "info",
  messageClass: "info",

  setup() {
    if (!this.hasSubscriptions) {
      this.set("messageKey", this.authenticated ? "not_subscribed" : "authorize");
    } else {
      this.set(
        "messageKey",
        !this.authenticated ? "please_authenticate" : "subsciptions_listed"
      );
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
              updated_at: result.updated_at,
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
  }
});
