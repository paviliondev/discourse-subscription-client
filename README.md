# Discourse Subscription Client

Manage your Discourse plugin subscriptions using this plugin.

### Install

Follow the [plugin installation guide](https://meta.discourse.org/t/install-a-plugin/19157).

### Configuration

You'll first need to get a subscription on your plugin supplier's website or forum.

Once you've got a subscription, go to the admin panel of the forum where this plugin is installed, click "Plugins", then "Subscriptions" on the left and follow the prompts.

### Who has access

Admins can do everything, including:

- Authorize a supplier
- See subscriptions
- See all notices (including dismissed and expired)

By default moderators can
- See subscriptions
- See active notices

You can allow moderators to authorize a supplier, allowing the forum to use a subscription the moderator has with the supplier, if you enable the site setting `subscription client allow moderator supplier authorization`.

### Notices

Your subscription supplier may send you messages about your subscription, or their plugin. These will appear in the "Notices" tab in the subscription client and create a purple notification next to the site menu (the hamburger menu).

If they send you a notice warning you about something (e.g. if their plugin is incompatible with the latest discourse) this will also appear in your admin dashboard as a warning.

You can prevent warning notices from appearing in your admin dashboard by turning off the site setting `subscription client warning notices on dashboard`.
