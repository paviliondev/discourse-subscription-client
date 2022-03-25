import DiscourseRoute from "discourse/routes/discourse";
import SubscriptionClient from "../models/subscription-client";

export default DiscourseRoute.extend({
  model() {
    return SubscriptionClient.show();
  },

  afterModel() {
    this.transitionTo("adminPlugins.subscriptionClient.subscriptions");
  },

  setupController(controller, model) {
    controller.setProperties({
      featuredNotices: model.featured_notices,
      activeNoticeCount: model.active_notice_count,
      authorizedSupplierCount: model.authorized_supplier_count,
      resourceCount: model.resource_count,
    });
    controller.subscribe();
  },
});
