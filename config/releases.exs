import Config

#Testing local variable
config :blog, BlogWeb.Endpoint, secret_key_base: System.fetch_env!("PROD_SECRET_KEY")
config :blog, Blog.Subscription.Mailgun, password: System.fetch_env!("PROD_MAIL_KEY")
