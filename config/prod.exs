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
  password: "key-ef2a9b6e6cad2b2beccf0518a6068107"

config :blog, Blog.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  url: "postgresql://blog_user:ffvyte83z9ypzvby@db-postgresql-sfo2-15967-do-user-7439692-0.a.db.ondigitalocean.com:25060/blog_prod?sslmode=require"

# Do not print debug messages in production
config :logger, level: :info


