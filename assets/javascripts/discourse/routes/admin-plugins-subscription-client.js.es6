import DiscourseRoute from "discourse/routes/discourse";
import SubscriptionClient from "../models/subscription-client";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClient.show();
  },

  afterModel() {
    this.transitionTo('adminPlugins.subscriptionClient.suppliers')
  },

  setupController(controller, model) {
    controller.setProperties({
      authentication: model.authentication,
      featuredNotices: model.featured_notices,
      activeNoticeCount: model.active_notice_count
    });
    controller.subscribe();
  }
});
