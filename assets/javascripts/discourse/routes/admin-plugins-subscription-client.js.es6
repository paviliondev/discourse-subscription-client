import DiscourseRoute from "discourse/routes/discourse";
import SubscriptionClient from "../models/subscription-client";

export default DiscourseRoute.extend({
  beforeModel() {
    if (!this.currentUser.can_manage_subscriptions) {
      this.set('noAccess', true);
      this.transitionTo("adminPlugins.subscriptionClient.noAccess");
    }
  },

  model(model, transition) {
    if (this.noAccess) {
      return {};
    } else {
      return SubscriptionClient.show();
    }
  },

  afterModel(model, transition) {
    if (transition.to.name === "adminPlugins.subscriptionClient.index") {
      this.transitionTo("adminPlugins.subscriptionClient.subscriptions");
    }
  },

  setupController(controller, model) {
    if (this.noAccess) {
      controller.setProperties({
        noAccess: true
      });
    } else {
      controller.setProperties({
        authorizedSupplierCount: model.authorized_supplier_count,
        resourceCount: model.resource_count,
      });
      controller.subscribe();
    }
  },
});
