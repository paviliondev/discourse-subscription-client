import DiscourseRoute from "discourse/routes/discourse";
import SubscriptionClient from "../models/subscription-client";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClient.show();
  },

  afterModel(model, transition) {
    if (transition.to.name === "adminPlugins.subscriptionClient.index") {
      this.transitionTo("adminPlugins.subscriptionClient.subscriptions");
    }
  },

  setupController(controller, model) {
    controller.setProperties({
      authorizedSupplierCount: model.authorized_supplier_count,
      resourceCount: model.resource_count,
    });
    controller.subscribe();
  },
});
