import Component from "@ember/component";
import NoticeMessage from "../mixins/notice-message";

export default Component.extend(NoticeMessage, {
  tagName: "tr",
  attributeBindings: ["notice.id:data-notice-id"],
  classNameBindings: [
    ":plugin-subscriptions-notice-row",
    "notice.typeClass",
    "notice.expired:expired",
    "notice.dismissed:dismissed",
  ],

  actions: {
    dismiss() {
      this.notice.dismiss();
    },
  },
});
