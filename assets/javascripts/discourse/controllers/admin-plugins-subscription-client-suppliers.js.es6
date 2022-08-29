import Controller from "@ember/controller";
import { notEmpty } from "@ember/object/computed";

export default Controller.extend({
  classNameBindings: [":suppliers"],
  hasSuppliers: notEmpty("suppliers"),
  messageKey: "info",
  messageClass: "info",
});
