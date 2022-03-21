import SubscriptionClientNotice from "../models/subscription-client-notice";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClientNotice.list({ include_all: true });
  },

  setupController(controller, model) {
    controller.setProperties({
      notices: A(
        model.notices.map((notice) => SubscriptionClientNotice.create(notice))
      ),
    });
  },
});
