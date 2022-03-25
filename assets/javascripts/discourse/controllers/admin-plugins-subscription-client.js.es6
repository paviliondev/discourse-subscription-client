import Controller, { inject as controller } from "@ember/controller";
import { isPresent } from "@ember/utils";
import { A } from "@ember/array";

export default Controller.extend({
  adminPluginsSubscriptionClientNotices: controller(),
  messageUrl: "https://thepavilion.io/t/3652",
  messageType: "info",
  messageKey: null,

  unsubscribe() {
    this.messageBus.unsubscribe("/subscription-client");
  },

  subscribe() {
    this.unsubscribe();
    this.messageBus.subscribe("/subscription-client", (data) => {
      if (isPresent(data.active_notice_count)) {
        this.set("activeNoticeCount", data.active_notice_count);
        this.adminPluginsSubscriptionClientNotices.setProperties({
          notices: A(),
          page: 0,
          canLoadMore: true,
        });
        this.adminPluginsSubscriptionClientNotices.loadMoreNotices();
      }
      if (isPresent(data.authorized_supplier_count)) {
        this.set("authorizedSupplierCount", data.authorized_supplier_count);
      }
    });
  },
});
