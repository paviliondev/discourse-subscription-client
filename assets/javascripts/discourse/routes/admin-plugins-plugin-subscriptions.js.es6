import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  model() {
    return {};
  },

  setupController(controller, model) {
    if (model.active_notice_count) {
      controller.set("activeNoticeCount", model.active_notice_count);
    }
    if (model.featured_notices) {
      controller.set("featuredNotices", model.featured_notices);
    }

    controller.subscribe();
  },
});
