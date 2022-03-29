import {
  acceptance,
  count,
  exists,
  queryAll,
  updateCurrentUser,
} from "discourse/tests/helpers/qunit-helpers";
import { click, visit } from "@ember/test-helpers";
import fixtures from "../fixtures/subscription-client-fixtures";
import { test } from "qunit";

acceptance("Subscription Client - Hamburger Menu", function (needs) {
  needs.user();
  needs.settings({ subscription_client_enabled: true });

  test("As a staff member with notices", async function (assert) {
    updateCurrentUser({
      moderator: true,
      admin: false,
      subscription_notice_count: 2,
    });

    await visit("/");
    assert.strictEqual(
      queryAll(
        "#toggle-hamburger-menu .badge-notification.subscription-notice"
      ).text(),
      "2"
    );

    await click(".hamburger-dropdown");
    assert.strictEqual(
      queryAll(
        ".subscription-notices .badge-notification.subscription-notice"
      ).text(),
      "2"
    );
  });
});

acceptance("Subscription Client - Admin", function (needs) {
  needs.user({ admin: false });
  needs.settings({ subscription_client_enabled: true });
  needs.pretender((server, helper) => {
    server.get("/admin/plugins/subscription-client.json", () =>
      helper.response(fixtures["/admin/plugins/subscription-client.json"])
    );
    server.get("/admin/plugins/subscription-client/subscriptions", () =>
      helper.response(
        fixtures["/admin/plugins/subscription-client/subscriptions.json"]
      )
    );
    server.get("/admin/plugins/subscription-client/notices", () =>
      helper.response(
        fixtures["/admin/plugins/subscription-client/notices.json"]
      )
    );
    server.get("/admin/plugins/subscription-client/suppliers", () =>
      helper.response(
        fixtures["/admin/plugins/subscription-client/suppliers.json"]
      )
    );
  });

  test("Lists subscriptions", async function (assert) {
    await visit("/admin/plugins/subscription-client/subscriptions");
    assert.strictEqual(count("tr.subscription-client-subscription-row"), 2);
    assert.strictEqual(
      queryAll("tr.subscription-client-subscription-row .supplier-name")
        .first()
        .text()
        .trim(),
      "Supplier 1"
    );
  });

  test("Lists notices", async function (assert) {
    await visit("/admin/plugins/subscription-client/notices");
    assert.strictEqual(count("tr.subscription-client-notice-row"), 2);
    assert.strictEqual(
      count("tr.subscription-client-notice-row .btn-toggle-message"),
      2
    );
    assert.ok(exists("tr.subscription-client-notice-row .btn-hide"));
    assert.ok(exists("tr.subscription-client-notice-row .btn-dismiss"));
    assert.strictEqual(
      queryAll("tr.subscription-client-notice-row .notice-source")
        .last()
        .text()
        .trim(),
      "Supplier 1"
    );
    assert.strictEqual(
      queryAll("tr.subscription-client-notice-row .notice-resource")
        .last()
        .text()
        .trim(),
      "discourse-plugin-1"
    );
  });

  test("Lists suppliers", async function (assert) {
    await visit("/admin/plugins/subscription-client/suppliers");
    assert.strictEqual(count("tr.subscription-client-supplier-row"), 1);
    assert.ok(exists(`tr.subscription-client-supplier-row img.avatar`));
    assert.ok(exists(`tr.subscription-client-supplier-row a.deauthorize`));
  });
});
