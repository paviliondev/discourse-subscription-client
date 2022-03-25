import SubscriptionClientSubscription from "../models/subscription-client-subscription";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClientSubscription.list();
  },

  setupController(controller, model) {
    controller.setProperties({
      subscriptions: A(model.subscriptions),
    });
  },
});
