import PluginSubscriptionsSubcription from "../models/plugin-subscriptions-subscription";
import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  model() {
    return PluginSubscriptionsSubcription.list({ include_all: true });
  },

  setupController(controller, model) {
    controller.set("model", model);
    controller.setup();
  },

  actions: {
    authorize() {
      PluginSubscriptionsSubcription.authorize();
    },
  },
});
