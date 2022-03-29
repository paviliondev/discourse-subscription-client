import Component from "@ember/component";
import NoticeMessage from "../mixins/notice-message";
import { readOnly } from "@ember/object/computed";

export default Component.extend(NoticeMessage, {
  tagName: "tr",
  attributeBindings: ["notice.id:data-notice-id"],
  classNameBindings: [
    ":subscription-client-notice-row",
    "notice.typeClass",
    "notice.expired:expired",
    "notice.dismissed:dismissed",
  ],
  canHide: readOnly("can_hide"),

  actions: {
    dismiss() {
      this.notice.dismiss();
    },

    hide() {
      this.notice.hide();
    },

    show() {
      this.notice.show();
    },
  },
});
