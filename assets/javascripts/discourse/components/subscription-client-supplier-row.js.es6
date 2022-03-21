import Component from "@ember/component";
import SubscriptionClient from "../models/subscription-client";
import { alias } from "@ember/object/computed";

export default Component.extend(NoticeMessage, {
  tagName: 'tr',
  classNames: ["supplier-row"],
  authorized: alias('supplier.api_key'),

  actions: {
    authorize(supplier) {
      SubscriptionClient.authorize(supplier.id);
    },

    unauthorize(supplier) {
      this.set("unauthorizing", true);

      SubscriptionClient.unauthorize(supplier.id)
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
