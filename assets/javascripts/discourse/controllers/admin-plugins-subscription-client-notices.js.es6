import Controller from "@ember/controller";
import SubscriptionClientNotice from "../models/subscription-client-notice";
import discourseComputed from "discourse-common/utils/decorators";
import { notEmpty } from "@ember/object/computed";
import { A } from "@ember/array";
import I18n from "I18n";
import bootbox from "bootbox";

export default Controller.extend({
  messageUrl: "https://thepavilion.io/t/3652",
  messageKey: "info",
  messageClass: "info",
  hasNotices: notEmpty("notices"),
  page: 0,
  loadingMore: false,
  canLoadMore: true,

  @discourseComputed("notices.[]", "notices.@each.dismissed")
  allDismisssed(notices) {
    return notices.every((n) => !n.canDismiss || n.dismissed);
  },

  loadMoreNotices() {
    if (!this.canLoadMore) {
      return;
    }
    const page = this.get("page");
    this.set("loadingMore", true);

    SubscriptionClientNotice.list({ page, include_all: true })
      .then((result) => {
        if (result.notices.length === 0) {
          this.set("canLoadMore", false);
          return;
        }

        this.get("notices").pushObjects(
          A(
            result.notices.map((notice) =>
              SubscriptionClientNotice.create(notice)
            )
          )
        );
      })
      .finally(() => this.set("loadingMore", false));
  },

  actions: {
    loadMore() {
      if (this.canLoadMore) {
        this.set("page", this.page + 1);
        this.loadMoreNotices();
      }
    },

    dismissAll() {
      bootbox.confirm(
        I18n.t("admin.subscription_client.notice.dismiss_all.confirm"),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        (result) => {
          if (result) {
            this.set("loadingMore", true);
            SubscriptionClientNotice.dismissAll().finally(() =>
              this.set("loadingMore", false)
            );
          }
        }
      );
    },
  },
});
