defmodule BlogWeb.AboutLive.Index do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:menu, "about")
    }
  end

  defp page_title(:index), do: "Andrew Barr"
end
