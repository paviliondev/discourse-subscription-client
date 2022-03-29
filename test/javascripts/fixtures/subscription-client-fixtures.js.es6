export default {
  "/admin/plugins/subscription-client.json": {
    authorized_supplier_count: 1,
    resource_count: 1
  },
  "/admin/plugins/subscription-client/subscriptions.json": {
    subscriptions: [
      {
        supplier_name: "Supplier 1",
        resource_name: "discourse-plugin-1",
        product_name: "Business",
        price_name: "yearly",
        active: true,
        updated_at: "2022-03-28T11:43:04.936Z"
      },
      {
        supplier_name: "Supplier 1",
        resource_name: "discourse-plugin-1",
        product_name: "Standard",
        price_name: "monthly",
        active: true,
        updated_at: "2022-03-28T11:43:04.946Z"
      }
    ]
  },
  "/admin/plugins/subscription-client/notices.json": {
    notices: [
      {
        id: 1,
        title: "Unable to connect to the plugin status server",
        message: "Please check your plugins' statuses before updating Discourse.",
        notice_type: "connection_error",
        notice_subject_type: "SubscriptionClientResource",
        notice_subject_id: -1,
        plugin_status_resource: true,
        created_at: "2022-03-25T10:35:16.867Z",
        expired_at: null,
        updated_at: "2022-03-29T13:51:10.317Z",
        dismissed_at: null,
        retrieved_at: null,
        hidden_at: null,
        dismissable: false,
        can_hide: true
      },
      {
        id: 2,
        title: "This is a message",
        message: "This is the body of the message",
        notice_type: "info",
        notice_subject_type: "SubscriptionClientResource",
        notice_subject_id: 1,
        plugin_status_resource: false,
        created_at: "2022-03-29T10:55:06.803Z",
        expired_at: null,
        updated_at: "2022-03-29T11:42:22.217Z",
        dismissed_at: null,
        retrieved_at: "2022-03-29T10:55:06.802Z",
        hidden_at: null,
        dismissable: true,
        can_hide: false,
        supplier: {
          id: 3,
          name: "Supplier 1",
          authorized: true,
          authorized_at: "2022-03-26T12:24:02.987Z",
          user: {
            id: 1,
            username: "angus",
            name: null,
            avatar_template: "/user_avatar/localhost/angus/{size}/3_2.png"
          }
        },
        resource: {
          id: 1,
          name: "discourse-plugin-1"
        }
      }
    ],
    hidden_notice_count: 1
  },
  "/admin/plugins/subscription-client/suppliers.json": [
    {
      id: 3,
      name: "Supplier 1",
      authorized: true,
      authorized_at: "2022-03-26T12:24:02.987Z",
      user: {
        id: 1,
        username: "angus",
        name: null,
        avatar_template: "/user_avatar/localhost/angus/{size}/3_2.png"
      }
    }
  ]
};
