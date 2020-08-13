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
  ],
  secret_key_base: "trfMak2t2RxNga25lfKVN/y1hIO8cTIT9l7V7tZ2FSSl2bDz+L3O3FemnvrkzLjy"

config :blog, Blog.Subscription.Mailgun,
  list: "weather@newsletter.ducksnutsfishing.com",
  base_url: "https://api.mailgun.net/v3/",
  username: "api",
  password:  System.get_env("TEST_MAIL_KEY")

config :blog, Blog.Mail.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key:  System.get_env("TEST_MAIL_KEY"),
  domain: "newsletter.ducksnutsfishing.com"


# Do not print debug messages in production
config :logger, level: :info

config :blog, Blog.Mail.Newsletter,
  to_email: "weather@newsletter.ducksnutsfishing.com"
