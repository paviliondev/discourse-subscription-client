import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import EmberObject from "@ember/object";

const PluginSubscriptionsSubscription = EmberObject.extend();

const basePath = "/admin/plugins/plugin-subs";

PluginSubscriptionsSubscription.reopenClass({
  status() {
    return ajax(`${basePath}/subscriptions`, {
      type: "GET",
    }).catch(popupAjaxError);
  },

  authorize() {
    window.location.href = `${basePath}/authorize`;
  },

  unauthorize() {
    return ajax(`${basePath}/authorize`, {
      type: "DELETE",
    }).catch(popupAjaxError);
  },

  update() {
    return ajax(basePath, {
      type: "POST",
    }).catch(popupAjaxError);
  },

  list(data = {}) {
    return ajax(`${basePath}/subscriptions`, {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },
});

export default PluginSubscriptionsSubscription;
