import { getOwner } from "discourse-common/lib/get-owner";

export default {
  shouldRender(attrs, ctx) {
    return ctx.siteSettings.subscription_client_critical_notices_on_dashboard;
  },

  setupComponent(attrs, component) {
    const controller = getOwner(this).lookup("controller:admin-dashboard");

    component.set("notices", controller.get("criticalNotices"));
    controller.addObserver("criticalNotices.[]", () => {
      if (this._state === "destroying") {
        return;
      }
      component.set("notices", controller.get("criticalNotices"));
    });
  },
};
