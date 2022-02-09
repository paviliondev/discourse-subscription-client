import Component from "@ember/component";
import PluginSubscription from "../models/plugin-subscriptions-subscription";
import { notEmpty } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

export default Component.extend({
  classNameBindings: [
    ":plugin-subscription",
    "subscription.active:active:inactive",
  ],
  subscribed: notEmpty("subscriptions"),

  @discourseComputed("subscribed")
  title(subscribed) {
    return subscribed
      ? I18n.t("admin.plugin_subscriptions.subscriptions.have_subscriptions")
      : I18n.t("admin.plugin_subscriptions.subscriptions.no_subscriptions");
  },

  @discourseComputed("subscription.active")
  stateClass(active) {
    return active ? "active" : "inactive";
  },

  @discourseComputed("stateClass")
  stateLabel(stateClass) {
    return I18n.t(
      `admin.plugin_subscriptions.subscription.subscription.status.${stateClass}`
    );
  },

  actions: {
    update() {
      this.set("updating", true);
      PluginSubscription.update()
        .then((result) => {
          if (result.success) {
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
