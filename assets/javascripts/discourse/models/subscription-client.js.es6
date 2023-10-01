import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import EmberObject from "@ember/object";

const SubscriptionClient = EmberObject.extend();
const baseUrl = window.location.href.split("/admin");
const basePath = baseUrl[0] + "/admin/plugins/subscription-client";

SubscriptionClient.reopenClass({
  show() {
    return ajax(`${basePath}.json`).catch(popupAjaxError);
  },

  authorize(supplierId) {
    window.location.href = `${basePath}/authorize?supplier_id=${supplierId}`;
  },

  deauthorize(supplierId) {
    return ajax(`${basePath}/authorize`, {
      type: "DELETE",
      data: {
        supplier_id: supplierId,
      },
    }).catch(popupAjaxError);
  },
});

export default SubscriptionClient;
