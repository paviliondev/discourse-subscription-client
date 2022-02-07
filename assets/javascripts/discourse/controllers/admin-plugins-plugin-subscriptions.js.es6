import Controller, { inject as controller } from "@ember/controller";
import { isPresent } from "@ember/utils";
import { A } from "@ember/array";

export default Controller.extend({
  adminPluginsPluginSubscriptionsNotices: controller(),

  unsubscribe() {
    this.messageBus.unsubscribe("/plugin-subs/notices");
  },

  subscribe() {
    this.unsubscribe();
    this.messageBus.subscribe("/plugin-subs/notices", (data) => {
      if (isPresent(data.active_notice_count)) {
        this.set("activeNoticeCount", data.active_notice_count);
        this.adminPluginsPluginSubscriptionsNotices.setProperties({
          notices: A(),
          page: 0,
          canLoadMore: true,
        });
        this.adminPluginsPluginSubscriptionsNotices.loadMoreNotices();
      }
    });
  },
});
