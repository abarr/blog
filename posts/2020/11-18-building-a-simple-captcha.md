==title==
 Building a Simple Captcha
==author==
 Andrew Barr
==description==
 I have a simple Phoenix website with a LiveView message component and wanted a simple captcha function
==tags==
 Elixr, Development
==body==

 
## Background

I have a website [Foxtail Consulting](https://foxtail.consulting) which I converted from Wordpress to a Phoenix website with `--no-ecto` and hosted on a $5/mo Digital Ocean Droplet. I wanted to add a simple contact form that did not require a database. Because the website is built using Phoenix LiveView I decided to use a `live_component` but needed a simple captcha to make any attempt at spamming the form fail (NOTE: I know this solution is not infallable but wanted to play around with `live_components`).

## Process

First I created a `context` called `contact` and created an `embedded_schema` (No database remember). 

```
defmodule MyApp.Contact.Message do
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:text, :string)
    field(:answer, :integer)
  end

  def changeset(message, attrs \\ %{}) do
    message
    |> cast(attrs, [:name, :email, :text, :answer])
    |> validate_required([:name, :email, :text, :answer])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:email, max: 160)
  end
end
```

I also created a `Mailer` module and a `Mail` module in the `context` to handle sending the email directly to my inbox. For my website I am using [Swoosh](https://hex.pm/packages/swoosh), an excellent email library with lots of adapters. 

I then created a new directory under the `live` folder called `components` and created the component file itself.

```
live
 |_ components
    |_ message_component.ex    
```



```

defmodule MyAppWeb.Components.MessageComponent do
  use MyAppWeb, :live_component
  alias MyApp.Contact.{Message, Mail}

  @catcha_notations ["+", "x"]

  @impl true
  def render(assigns) do
    ~L"""
      <%= live_flash(@flash, :success) %>
      <%= live_flash(@flash, :error) %>
      <%= f = form_for 
        @changeset, 
        "#", 
        phx_target: @myself, 
        phx_change: "validate", 
        phx_submit: "send_message" 
      %>
  
        <%= text_input f, :name, [phx_debounce: "blur"] %>
        <%= error_tag f, :name %>
        
        <%= text_input f, :email, [phx_debounce: "blur"] %>
        <%= error_tag f, :email %>
        
        <%= textarea f, :text, [phx_debounce: "blur"] %>
        <%= error_tag f, :text %>
        
        <div>
          <%= @v1 %> <%= @operation %> <%= @v2 %> =
          <%= text_input f, :answer, [phx_debounce: "blur"] %>
        </div>
        <%= error_tag f, :answer %></span>
        
        <%= submit "Send Message", phx_disable_with: "Saving ...." %>
        
      </form>
    """
  end

  def mount(_assigns, socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    changeset = Message.changeset(%Message{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_captcha()}
  end

  @impl true
  def handle_event( "send_message",%{ "message" => message}, socket) do

    changeset =
      %Message{}
      |> Message.changeset(message)
      |> Map.put(:action, :validate)

    %{"name" => name, "email" => email, "text" => message, "answer" => answer} = message

    cond do
      !captcha?(socket.assigns.operation, answer, socket) ->
        {:noreply,
        socket
        |> clear_flash()
        |> put_flash(:error, "Doh! No good at math? Try again")
        |> assign(:changeset, changeset)
        |> assign_captcha()
      }

      changeset.valid? && captcha?(socket.assigns.operation, answer, socket) ->
        case Mail.send(name, email, message) do
          {:ok, _msg} ->
            {:noreply,
            socket
            |> put_flash(:success, "Your message is on its way!")
            |> assign(:changeset, Message.changeset(%Message{}))
            |> assign_captcha()}

          {:error, _msg} ->
            {:noreply,
            socket
            |> clear_flash()
            |> put_flash(:error, "Whoops! Please check your details")
            |> assign(:changeset, changeset)
            |> assign_captcha()}
        end

      true ->
        {:noreply,
            socket
            |> assign(:changeset, changeset)
            |> assign_captcha()}
    end

  end

  @impl true
  def handle_event("validate", %{"message" => message}, socket) do
    changeset =
      %Message{}
      |> Message.changeset(message)
      |> Map.put(:action, :validate)

    {:noreply,
      socket
      |> assign(:changeset, changeset)
      |> clear_flash()
    }
  end

  defp assign_captcha(socket) do
    socket
    |> assign(:v1, :rand.uniform(9))
    |> assign(:v2, :rand.uniform(9))
    |> assign(:operation, Enum.random(@catcha_notations))
  end

  defp captcha?(_, "", _), do: false

  defp captcha?("x", answer, %{assigns: %{v1: v1, v2: v2}}) do
    cond do
      v1 * v2 != String.to_integer(answer) -> false
      true -> true
    end
  end

  defp captcha?("+", answer, %{assigns: %{v1: v1, v2: v2}}) do
    cond do
      v1 + v2 != String.to_integer(answer) -> false
      true -> true
    end
  end

  defp captcha?(_, _answer, _socket), do: false
end

```


There are some notable parts for the `message_component.ex`. Ensure that you use `use MyAppWeb, :live_component` in your file and in the form include `phx_target: @myself`. This will ensure that the events captured by the parent `LiveView` will be passed to the components `handle` functions. Additionally, because the component is stateful when you embed it in the parent `LiveView` be sure to add and `id`.

```
<%= live_component( @socket, MayAppWeb.Components.MessageComponent, id: :message) %>
```

Apart from that the setup is pretty straight forward. When the user submits the form (assuming they have passed through the validation event) I get the answer provided together with the operation and test it using the values recorded in the assigns. If the simple sum is correct I attempt to send their message via email.

Feel free to test it out and send me a message from my website if you have any feedback - [Foxtail Consulting](https://foxtail.consulting)

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>


<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>





