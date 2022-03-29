import Mixin from "@ember/object/mixin";
import { bind, scheduleOnce } from "@ember/runloop";
import { cookAsync } from "discourse/lib/text";
import { createPopper } from "@popperjs/core";

export default Mixin.create({
  showMessage: false,

  didReceiveAttrs() {
    const message = this.notice.message;
    cookAsync(message).then((cooked) => {
      this.set("cookedMessage", cooked);
    });
  },

  createMessageModal() {
    let container = this.element.querySelector(".notice-message");
    let modal = this.element.querySelector(".notice-message-content");

    this._popper = createPopper(container, modal, {
      strategy: "absolute",
      placement: "auto",
      modifiers: [
        {
          name: "preventOverflow",
        },
        {
          name: "offset",
          options: {
            offset: [0, 5],
          },
        },
      ],
    });
  },

  didInsertElement() {
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(event) {
    if (this._state === "destroying") {
      return;
    }

    if (
      !event.target.closest(
        `[data-notice-id="${this.notice.id}"] .notice-message`
      )
    ) {
      this.set("showMessage", false);
    }
  },

  actions: {
    toggleMessage() {
      this.toggleProperty("showMessage");

      if (this.showMessage) {
        scheduleOnce("afterRender", this, this.createMessageModal);
      }
    },
  },
});
