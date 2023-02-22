export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route(
      "subscriptionClient",
      { path: "/subscription-client" },
      function () {
        this.route("subscriptions", { path: "/subscriptions" });
        this.route("suppliers", { path: "/suppliers" });
        this.route("notices", { path: "/notices" });
        this.route("noAccess", { path: "/no-access" });
      }
    );
  },
};
