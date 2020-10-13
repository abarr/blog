use Mix.Config

config :blog, BlogWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [host: "andrewbarr.io", port: 80],
  check_origin: [
    "https://andrewbarr.io",
    "http://andrewbarr.io:4000",
    "https://www.andrewbarr.io",
    "http://www.andrewbarr.io:4000"
  ],
  secret_key_base: "trfMak2t2RxNga25lfKVN/y1hIO8cTIT9l7V7tZ2FSSl2bDz+L3O3FemnvrkzLjy"

# Do not print debug messages in production
config :logger, level: :info
