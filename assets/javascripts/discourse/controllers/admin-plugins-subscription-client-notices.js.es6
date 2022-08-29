import Controller from "@ember/controller";
import SubscriptionClientNotice from "../models/subscription-client-notice";
import { observes } from "discourse-common/utils/decorators";
import { gt, notEmpty } from "@ember/object/computed";
import { A } from "@ember/array";

export default Controller.extend({
  queryParams: ["all", "hidden"],
  messageKey: "info",
  messageClass: "info",
  hasNotices: notEmpty("notices"),
  hasHiddenNotices: gt("hiddenNoticeCount", 0),
  page: 0,
  loadingMore: false,
  canLoadMore: true,
  hidden: false,
  all: false,

  @observes("currentUser.subscription_notice_count")
  visibleNoticeCountChanged() {
    this.setProperties({
      notices: A(),
      page: 0,
      canLoadMore: true,
    });
    this.loadMoreNotices();
  },

  loadMoreNotices() {
    if (!this.canLoadMore) {
      return;
    }

    const opts = {
      page: this.get("page"),
      visible: !this.get("hidden"),
      include_all: this.get("all"),
    };

    this.set("loadingMore", true);

    SubscriptionClientNotice.list(opts)
      .then((result) => {
        this.set("hiddenNoticeCount", result.hidden_notice_count);

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

    toggleHidden(e) {
      if (e) {
        e.stopPropagation();
      }
      this.toggleProperty("hidden");
    },

    toggleAll(e) {
      if (e) {
        e.stopPropagation();
      }
      this.toggleProperty("all");
    },
  },
});
