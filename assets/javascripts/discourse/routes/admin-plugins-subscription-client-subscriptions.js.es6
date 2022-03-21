import SubscriptionClientSubscription from "../models/subscription-client-subscription";
import SubscriptionClient from "../models/subscription-client";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClientSubscription.list();
  },

  setupController(controller, model) {
    const parentController = this.controllerFor('adminPluginsSubscriptionClient');
    controller.setProperties({
      subscriptions: A(model),
      server: parentController.get('server'),
      authentication: parentController.get('authentication')
    });
    controller.setup();
  }
});
