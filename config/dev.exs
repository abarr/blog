use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :blog, BlogWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]


# Watch static and templates for browser reloading.
config :blog, BlogWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/blog_web/(live|views)/.*(ex)$",
      ~r"lib/blog_web/templates/.*(eex)$",
       ~r"posts/*/.*(md)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Config for testing adding a subscriber to a mailing list
config :blog, Blog.Subscription.Mailgun,
  list: "test@newsletter.ducksnutsfishing.com",
  base_url: "https://api.mailgun.net/v3/",
  username: "api",
  password: "key-ef2a9b6e6cad2b2beccf0518a6068107"

# config :blog, Blog.Mail.Mailer,
#   adapter: Swoosh.Adapters.Local


config :blog, Blog.Mail.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: "key-ef2a9b6e6cad2b2beccf0518a6068107",
  domain: "newsletter.ducksnutsfishing.com"

config :blog, Blog.Mail.Newsletter,
  to_email: "test@newsletter.ducksnutsfishing.com"

config :blog, Blog.Repo,
  username: "postgres",
  password: "postgres",
  database: "blog_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10


