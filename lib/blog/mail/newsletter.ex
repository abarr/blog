defmodule Blog.Mail.Newsletter do
  import Swoosh.Email

  def send() do
    to_email = Application.get_env(:blog, __MODULE__)[:to_email]
    latest_post = Blog.Posts.get_latest_post!()
    {:safe, body} = latest_post.body

    new()
    |> to(to_email)
    |> from({"The Duck", "weather@ducksnutsfishing.com"})
    |> subject(latest_post.title)
    |> html_body(body)
  end

end
