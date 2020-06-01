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

config :blog, Blog.Repo,
  # ssl: true,
  url: "postgresql://blog_user:ffvyte83z9ypzvby@db-postgresql-sfo2-15967-do-user-7439692-0.a.db.ondigitalocean.com:25060/blog?sslmode=require",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :logger, level: :warn


