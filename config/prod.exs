use Mix.Config

config :blog, BlogWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: "ducksnutsfishing.com", port: 80],
  check_origin: [
    "https://ducksnutsfishing.com",
    "http://ducksnutsfishing.com:4000",
    "https://www.ducksnutsfishing.com",
    "http://www.ducksnutsfishing.com:4000"
  ]

config :blog, Blog.Subscription.Mailgun,
  list: "weather@newsletter.ducksnutsfishing.com",
  base_url: "https://api.mailgun.net/v3/",
  username: "api"

config :blog, Blog.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# Do not print debug messages in production
config :logger, level: :info


