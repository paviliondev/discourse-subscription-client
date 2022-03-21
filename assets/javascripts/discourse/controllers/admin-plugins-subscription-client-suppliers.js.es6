import Controller from "@ember/controller";
import { notEmpty } from "@ember/object/computed";

export default Controller.extend({
  classNameBindings: [
    ":suppliers",
  ],
  hasSuppliers: notEmpty("suppliers"),
  messageUrl: "https://thepavilion.io/t/3652",
  messageKey: "info",
  messageClass: "info"
});
