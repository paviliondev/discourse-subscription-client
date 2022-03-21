import Controller, { inject as controller } from "@ember/controller";
import { default as discourseComputed } from "discourse-common/utils/decorators";
import { alias } from "@ember/object/computed";
import { isPresent } from "@ember/utils";
import { A } from "@ember/array";
import SubscriptionClient from "../models/subscription-client";

export default Controller.extend({
  adminPluginsSubscriptionClientNotices: controller(),
  messageUrl: "https://thepavilion.io/t/3652",
  messageType: "info",
  messageKey: null,
  authenticated: alias("authentication.active"),
  showSubscriptions: alias("authenticated"),

  @discourseComputed("server")
  messageOpts(server) {
    return { server };
  },

  unsubscribe() {
    this.messageBus.unsubscribe("/subscription-client/notices");
  },

  subscribe() {
    this.unsubscribe();
    this.messageBus.subscribe("/subscription-client/notices", (data) => {
      if (isPresent(data.active_notice_count)) {
        this.set("activeNoticeCount", data.active_notice_count);
        this.adminPluginsSubscriptionClientNotices.setProperties({
          notices: A(),
          page: 0,
          canLoadMore: true,
        });
        this.adminPluginsSubscriptionClientNotices.loadMoreNotices();
      }
    });
  }
});
