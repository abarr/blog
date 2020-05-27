defmodule BlogWeb.Components.SubscribeComponent do
  use BlogWeb, :live_component

  alias Blog.Subscription.{Subscriber, Mailgun}

  @impl true
  def render(assigns) do
    ~L"""
      <div>
        <div class="bg-gray-100 p-4 rounded-md">
         <%= f = form_for @changeset, "#", phx_target: @myself, phx_change: "validate", phx_submit: "subscribe" %>
          <div>
            <h4 class="mb-5 font-semibold">Subscribe to our newsletter</h4>

              <label for="email" class="block text-sm font-medium leading-5 text-gray-700">Email</label>
              <div class="mt-1 relative rounded-lg shadow-sm">
                <%= text_input f, :email, [class: "form-input block w-full sm:text-sm sm:leading-5", placeholder: "you@example.com"] %>
              </div>
              <%= error_tag f, :email %>
          </div>
          <span class="inline-flex rounded-md shadow-sm">
            <%= submit "Subscribe", phx_disable_with: "Saving...", class: "mt-5 inline-flex items-center px-3 py-2 border border-gray-300 text-base leading-6 font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 hover:text-gray-500focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150" %>
          </span>
          </form>
        </div>
        <%= if live_flash(@flash, :info) do %>
        <div class="rounded-md bg-green-50 pt-6 pl-4">
          <div class="flex">
            <div class="">
              <p class="text-sm leading-5 font-medium text-green-800" phx-click="lv:clear-flash" phx-value-key="info">
                <%= live_flash(@flash, :info) %>
              </p>
            </div>
          </div>
        </div>
        <% end %>
        <%= if live_flash(@flash, :error) do %>
        <div class="rounded-md bg-red-50 pt-6 pl-4">
          <div class="flex">
            <div class="">
              <p class="text-sm leading-5 font-medium text-red-800" phx-click="lv:clear-flash" phx-value-key="error">
                <%= live_flash(@flash, :error) %>
              </p>
            </div>
          </div>
        </div>
        <% end %>
        <div>


         </div>

         <div class="bg-white">
          <div class="max-w-screen-xl py-5 px-4 ">
            <h2 class="text-gray-400 ">Follow all our socials</h2>
            <div class="grid grid-cols-5 gap-1 ">
              <div class="col-span-1 flex justify-center 1">
                 <a href="https://www.instagram.com/ducksnutsfishing/" target="blank"><i class="fab fa-instagram fa-3x"></i></a>
              </div>
              <div class="col-span-1 flex justify-center ">
                <a href="https://www.facebook.com/ducksnutstackle" target="blank"><i class="fab fa-facebook-square fa-3x"></i></a>
              </div>
            </div>
          </div>
        </div>
      </div>



    """
  end

  def mount(_assigns, socket) do
    {:ok, socket }
  end

  @impl true
  def update(assigns, socket) do
    changeset = Subscriber.changeset(%Subscriber{})
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("subscribe",%{"subscriber" => %{"email" => email}}, socket) do
    changeset = Subscriber.changeset(%Subscriber{})
    case Mailgun.add_subscriber(email) do
       {:ok, msg } ->
          {:noreply,
              socket
              |> put_flash(:info, msg)
              |> assign(:changeset, changeset)
          }
       {:error, msg } ->
          {:noreply,
              socket
              |> put_flash(:error, msg)
              |> assign(:changeset, changeset)
          }
    end


  end

  @impl true
  def handle_event("validate", %{"subscriber" => subscriber}, socket) do
    changeset =
      %Subscriber{}
      |> Subscriber.changeset(subscriber)
      |> Map.put(:action, :validate)

    {:noreply,
      socket
      |> assign(:changeset, changeset)
      |> clear_flash
    }
  end
end
