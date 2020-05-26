defmodule BlogWeb.HomeLive.Index do
  use BlogWeb, :live_view
  alias Blog.Posts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:post, Posts.get_latest_post!())
      |> assign(:menu, "home")
    }
  end

end
