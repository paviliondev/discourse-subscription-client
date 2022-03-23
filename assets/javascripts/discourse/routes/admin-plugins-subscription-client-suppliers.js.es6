import SubscriptionClientSupplier from "../models/subscription-client-supplier";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClientSupplier.list();
  },

  setupController(controller, model) {
    controller.setProperties({
      suppliers: A(model)
    });
  }
});
