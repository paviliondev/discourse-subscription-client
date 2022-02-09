import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import PluginSubscriptionsSubscription from "../models/plugin-subscriptions-subscription";
import { alias } from "@ember/object/computed";
import { notEmpty } from "@ember/object/computed";

export default Controller.extend({
  hasSubscriptions: notEmpty("model.subscriptions"),
  messageUrl: "https://thepavilion.io/t/3652",
  messageType: "info",
  messageKey: null,
  showSubscriptions: alias("model.authentication.active"),

  setup() {
    const authentication = this.get("model.authentication");
    const subscriptions = this.get("model.subscriptions");
    //const subscribed = subscriptions && subscriptions.active;
    const authenticated = authentication && authentication.active;

    if (!this.hasSubscriptions) {
      this.set("messageKey", authenticated ? "not_subscribed" : "authorize");
    } else {
      this.set(
        "messageKey",
        !authenticated
          ? "please_authenticate"
          : "subsciptions_listed"
      );
    }
  },

  @discourseComputed("model.server")
  messageOpts(server) {
    return { server };
  },

  actions: {
    unauthorize() {
      this.set("unauthorizing", true);

      PluginSubscriptionsSubscription.unauthorize()
        .then((result) => {
          if (result.success) {
            this.setProperties({
              messageKey: "unauthorized",
              messageType: "warn",
              "model.authentication": null,
              "model.subscription": null,
            });
          } else {
            this.setProperties({
              messageKey: "unauthorize_failed",
              messageType: "error",
            });
          }
        })
        .finally(() => {
          this.set("unauthorizing", false);
        });
    },
  },
});
