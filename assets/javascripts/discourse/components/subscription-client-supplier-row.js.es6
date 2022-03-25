import Component from "@ember/component";
import SubscriptionClientSupplier from "../models/subscription-client-supplier";
import discourseComputed from "discourse-common/utils/decorators";
import { notEmpty } from "@ember/object/computed";
import I18n from "I18n";

export default Component.extend({
  tagName: "tr",
  classNames: ["supplier-row"],
  authorized: notEmpty("supplier.authorized_at"),

  @discourseComputed("supplier.authorized")
  status(authorized) {
    let key = authorized ? "authorized" : "not_authorized";
    return I18n.t(`admin.subscription_client.supplier.${key}`);
  },

  actions: {
    authorize() {
      SubscriptionClientSupplier.authorize(this.supplier.id);
    },

    deauthorize() {
      this.set("unauthorizing", true);

      SubscriptionClientSupplier.deauthorize(this.supplier.id)
        .then((result) => {
          if (result.success) {
            this.set("supplier", result.supplier);
          }
        })
        .finally(() => {
          this.set("unauthorizing", false);
        });
    },
  },
});
