import SubscriptionClientNotice from "../models/subscription-client-notice";
import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  queryParams: {
    all: { refreshModel: true },
    hidden: { refreshModel: true },
  },

  model(params) {
    return SubscriptionClientNotice.list({
      include_all: params.all,
      visible: !params.hidden,
    });
  },

  setupController(controller, model) {
    controller.setProperties({
      hiddenNoticeCount: model.hidden_notice_count,
      notices: A(
        model.notices.map((notice) => SubscriptionClientNotice.create(notice))
      ),
    });
  },
});
