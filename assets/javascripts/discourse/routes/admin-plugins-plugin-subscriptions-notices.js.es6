import PluginSubscriptionsNotice from "../models/plugin-subscriptions-notice";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return PluginSubscriptionsNotice.list({ include_all: true });
  },

  setupController(controller, model) {
    controller.setProperties({
      notices: A(
        model.notices.map((notice) => PluginSubscriptionsNotice.create(notice))
      ),
    });
  },
});
