defmodule Blog.Subscription.Mailgun do
  use Tesla

  plug Tesla.Middleware.BaseUrl, Application.get_env(:blog, __MODULE__)[:base_url]
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.BasicAuth,
    username: Application.get_env(:blog, __MODULE__)[:username],
    password: Application.get_env(:blog, __MODULE__)[:password]

  @list Application.get_env(:blog, __MODULE__)[:list]

  def add_subscriber(email) do
    case mailgun_post(email)  do
      {:ok, %{ status: 400 } = response } ->
        {:error, response.body["message"]}
      {:ok, _} ->
        {:ok, "Subscription successful!"}
    end
  end

  defp mailgun_post(email) do
    __MODULE__.post("lists/#{@list}/members",
      %{
        subscribed: "true",
        address: email
      }
    )
  end

end
