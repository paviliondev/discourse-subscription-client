import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { and, not, notEmpty } from "@ember/object/computed";
import { dasherize } from "@ember/string";
import I18n from "I18n";

const basePath = "/admin/plugins/subscription-client/notices";

const SubscriptionClientNotice = EmberObject.extend({
  expired: notEmpty("expired_at"),
  dismissed: notEmpty("dismissed_at"),
  hidden: notEmpty("hidden_at"),
  notHidden: not("hidden"),
  notDismissed: not("dismissed"),
  canDismiss: and("dismissable", "notDismissed"),
  canHide: and("can_hide", "notHidden"),

  @discourseComputed("notice_type")
  typeClass(noticeType) {
    return dasherize(noticeType);
  },

  @discourseComputed("notice_type")
  typeLabel(noticeType) {
    return I18n.t(`admin.subscription_client.notice.type.${noticeType}`);
  },

  dismiss() {
    if (!this.get("canDismiss")) {
      return;
    }

    return ajax(`${basePath}/${this.get("id")}/dismiss`, {
      type: "PUT",
    })
      .then((result) => {
        if (result.success) {
          this.set("dismissed_at", result.dismissed_at);
        }
      })
      .catch(popupAjaxError);
  },

  hide() {
    if (!this.get("canHide")) {
      return;
    }

    return ajax(`${basePath}/${this.get("id")}/hide`, {
      type: "PUT",
    })
      .then((result) => {
        if (result.success) {
          this.set("hidden_at", result.hidden_at);
        }
      })
      .catch(popupAjaxError);
  },

  show() {
    if (!this.get("hidden")) {
      return;
    }

    return ajax(`${basePath}/${this.get("id")}/show`, {
      type: "PUT",
    })
      .then((result) => {
        if (result.success) {
          this.set("hidden_at", null);
        }
      })
      .catch(popupAjaxError);
  },
});

SubscriptionClientNotice.reopenClass({
  list(data = {}) {
    return ajax(`${basePath}`, {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },
});

export default SubscriptionClientNotice;
