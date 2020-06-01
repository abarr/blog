use Mix.Config

secret_key_base = System.fetch_env!("PROD_SECRET_KEY")

config :blog, BlogWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

config :blog, Blog.Subscription.Mailgun,
  list: "weather@newsletter.ducksnutsfishing.com",
  base_url: "https://api.mailgun.net/v3/",
  username: "api",
  password: System.fetch_env!("PROD_MAIL_KEY")

database_url = ""

config :blog, Blog.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# Do not print debug messages in production
config :logger, level: :info


