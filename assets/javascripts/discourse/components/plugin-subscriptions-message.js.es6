import { default as discourseComputed } from "discourse-common/utils/decorators";
import { not, notEmpty } from "@ember/object/computed";
import Component from "@ember/component";
import I18n from "I18n";

const icons = {
  error: "times-circle",
  success: "check-circle",
  warn: "exclamation-circle",
  info: "info-circle",
};

export default Component.extend({
  classNameBindings: [":plugin-subscriptions-message", "type", "loading"],
  showDocumentation: not("loading"),
  showIcon: not("loading"),
  hasItems: notEmpty("items"),

  @discourseComputed("type")
  icon(type) {
    return icons[type] || "info-circle";
  },

  @discourseComputed("key", "component", "opts")
  message(key, component, opts) {
    return I18n.t(
      `admin.plugin_subscriptions.message.${component}.${key}`,
      opts || {}
    );
  },

  @discourseComputed("component")
  documentation(component) {
    return I18n.t(
      `admin.plugin_subscriptions.message.${component}.documentation`
    );
  },
});
