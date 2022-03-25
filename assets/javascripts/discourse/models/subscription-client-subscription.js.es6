import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import EmberObject from "@ember/object";

const SubscriptionClientSubscription = EmberObject.extend();
const basePath = "/admin/plugins/subscription-client";

SubscriptionClientSubscription.reopenClass({
  status() {
    return ajax(`${basePath}/subscriptions`, {
      type: "GET",
    }).catch(popupAjaxError);
  },

  update() {
    return ajax(`${basePath}/subscriptions`, {
      type: "POST",
    }).catch(popupAjaxError);
  },

  list() {
    return ajax(`${basePath}/subscriptions`).catch(popupAjaxError);
  },
});

export default SubscriptionClientSubscription;
