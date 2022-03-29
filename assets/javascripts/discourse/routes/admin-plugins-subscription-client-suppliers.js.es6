import SubscriptionClientSupplier from "../models/subscription-client-supplier";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";
import User from "discourse/models/user";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClientSupplier.list();
  },

  setupController(controller, model) {
    const suppliers = model.map((supplier) => {
      if (supplier.user) {
        supplier.user = User.create(supplier.user);
      }
      return supplier;
    });
    controller.setProperties({
      suppliers: A(suppliers),
    });
  },
});
