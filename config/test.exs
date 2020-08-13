use Mix.Config

config :blog, BlogWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4002"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: System.get_env("TEST_SECRET_KEY"),
  url: [host: "test.ducksnutsfishing.com", port: 80],
  check_origin: [
    "https://test.ducksnutsfishing.com",
    "http://test.ducksnutsfishing.com:4002"
  ]

config :blog, Blog.Subscription.Mailgun,
  list: "test@newsletter.ducksnutsfishing.com",
  base_url: "https://api.mailgun.net/v3/",
  username: "api",
  password: System.get_env("TEST_MAIL_KEY")

config :logger, level: :warn
