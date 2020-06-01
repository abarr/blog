use Mix.Config

config :blog, BlogWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4002"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: "" ,
  url: [host: "test.ducksnutsfishing.com", port: 80],
  check_origin: [
    "https://test.ducksnutsfishing.com",
    "http://test.ducksnutsfishing.com:4002"
  ]

config :blog, Blog.Subscription.Mailgun,
  list: "test@newsletter.ducksnutsfishing.com",
  base_url: "https://api.mailgun.net/v3/",
  username: "api",
  password: ""

database_url = ""

config :blog, Blog.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")