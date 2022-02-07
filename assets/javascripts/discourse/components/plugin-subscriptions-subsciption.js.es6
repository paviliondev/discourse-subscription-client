import Component from "@ember/component";
import PluginSubscription from "../models/plugin-subscription";
import { notEmpty } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

export default Component.extend({
  classNameBindings: [
    ":plugin-subscription",
    "subscription.active:active:inactive",
  ],
  subscribed: notEmpty("subscription"),

  @discourseComputed("subscription.type")
  title(type) {
    return type
      ? I18n.t(`admin.plugin_subscriptions.subscription.subscription.title.${type}`)
      : I18n.t("admin.plugin_subscriptions.subscription.not_subscribed");
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
              subscription: result.subscription,
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
