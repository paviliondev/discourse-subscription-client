import Component from "@ember/component";
import SubscriptionClientSupplier from "../models/subscription-client-supplier";
import { alias } from "@ember/object/computed";

export default Component.extend({
  tagName: 'tr',
  classNames: ["supplier-row"],
  authorized: alias('supplier.api_key'),

  actions: {
    authorize(supplier) {
      SubscriptionClientSupplier.authorize(supplier.id);
    },

    unauthorize(supplier) {
      this.set("unauthorizing", true);

      SubscriptionClientSupplier.unauthorize(supplier.id)
        .then((result) => {
          if (result.success) {
            this.set('supplier', result.supplier)
          }
        })
        .finally(() => {
          this.set("unauthorizing", false);
        });
    },
  }
});
