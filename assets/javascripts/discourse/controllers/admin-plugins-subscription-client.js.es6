import Controller, { inject as controller } from "@ember/controller";
import { isPresent } from "@ember/utils";

export default Controller.extend({
  adminPluginsSubscriptionClientNotices: controller(),
  messageType: "info",
  messageKey: null,

  unsubscribe() {
    this.messageBus.unsubscribe("/subscription_client");
  },

  subscribe() {
    this.unsubscribe();
    this.messageBus.subscribe("/subscription_client", (data) => {
      if (isPresent(data.authorized_supplier_count)) {
        this.set("authorizedSupplierCount", data.authorized_supplier_count);
      }
    });
  },
});
