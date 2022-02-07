export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route("plugin-subscriptions", { path: "/plugin-subs" }, function () {
      this.route("subscriptions", {
        path: "/subscriptions",
      });
      this.route("notices", {
        path: "/notices",
      });
    });
  },
};
