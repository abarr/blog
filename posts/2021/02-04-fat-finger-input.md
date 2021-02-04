==title==
 Fat Finger Input
==author==
 Andrew Barr
==description==
 Recently I was thinking about an input form for 'fat fingered operators' and came up with a Liveview version
==tags==
 elixir
==body==

 Premise
 ----------

I was recently chatting with someone about an application for use in the mining sector. One of the topics was a simple input form for operators who notoriously hate using technology solutions for data input. One of the terms used was 'fat fingered operators' (hence the title of the post). Before anyone gets upset it wasn't meant as a derogitory term but rather as a flag to think of simple robust methods to make peoples jobs easier.

We talked about QR Codes, Image Recognition and AI as ways of automatically understanding what the operator was looking at and what type of data they are trying to capture and record. It would be fun to work on all of these solutions but I started to think about a fast simple solution that might be viable.

 Idea
 ----------

I had recently seen someone walking along using the voice to text funtion on their phone and it occurred to me that it might be a simple solution to save our operators having to search or type input when recording data. I spent a couple of hours playing around with Liveview and came up with the following POC:

<p>&nbsp;</p>
<div style="display: flex; justify-content: center;">
    <img  src="/images/Hnet-image.gif"></img>
</div>
<p>&nbsp;</p>

The Monitoring device input is an autocomplete `text-input`, using my iPhone I selected the dictation icon and said 'orange' which provided a list of options. After selecting the device I entered the value using a large number pad.

 The Code
 ----------

I started by creating a Phoenix Live application called `fat_fingers`

```
> mix phx.new --live --no-ecto
```

I am currently in love with [Tailwind](https://tailwindcss.com) so spent a little bit of time setting it up. I have removed the css from the code below for simplicity.

I modified the default `PageLive` for my POC adding in assigns to capture `matches`, `value` and to record the `device` once selected.

```
defmodule FatFingersWeb.PageLive do
  use FatFingersWeb, :live_view

  alias FatFingers.Devices

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
      device: nil,
      matches: [],
      value: "_"
      )
    {:ok, socket}
  end
end
```

I added a module to act as a search context

```
defmodule FatFingers.Devices do

  def suggest(""), do: []

  def suggest(val) do
    Enum.filter(list(), fn d ->
      String.contains?(String.downcase(d), String.downcase(val)) end
      )
  end

  defp list() do
    [
      "Black",
      "Green",
      "Blue",
      "Pink",
      "Red",
      "Orange",
      "Purple"
    ]
  end

end

```

I knew I wanted to allow the User to search for a `device` and provide a list to select from so added an event handler to return matches and another one to handle the selection

```
@impl true
def handle_event("search", %{ "device" => device }, socket) do
socket = assign(socket, matches: Devices.suggest(device))
{:noreply, socket}
end

@impl true
def handle_event("select_match", %{ "match" => match}, socket) do
socket = assign(socket, device: match, matches: [])
{:noreply, socket}
end

```
The next step was to allow teh User to enter a value using a large number pad. Because I am simulating a cursor for the value as a default this event handler tests to see if `value` is in the default state. Otherwise it appends the added value.

```
@impl true
  def handle_event("number", %{ "number" => number}, socket) do
    cond do
      is_nil(socket.assigns.device) -> {:noreply, socket}
      true ->
        case socket.assigns.value do
          "_" ->
            socket = assign(socket, value: number)
            {:noreply, socket}
          _ ->
            socket = assign(socket, value: socket.assigns.value <> number)
            {:noreply, socket}
        end
    end
  end
```

Finally I wanted to allow the User to clear the value if they made an error

```
  @impl true
  def handle_event("clear", _, socket) do
    socket = assign(socket, value: "_")
    {:noreply, socket}
  end
```

In the `page_live.html.leex` I created a form and a large number pad

```
<form class="" phx-change="search">
 <div>
  <label>Monitoring Device</label>
  <div>
   <input value="<%= @device %>" placeholder="Device name ..."/>
    <div>
     <ul>
      <%= for m <- @matches do %>
       <li select-none phx-value-match="<%= m %>">
        <a href="#"><%= m %></a>
       </li>
      <% end %>
     </ul>
    </div>
   </div>
  </div>
  <div>
   <label>Enter Value:</label>
    <div>
     <div><%= @value %></div>
    </div>
     <input type="hidden" id="value" name="value" value="<%= @value %>">
    </div>
    <ul class="grid gap-6 grid-cols-3 mt-4 px-2">
    <%= for n <- 1..9 do %>
        <a href="#">
        <div phx-click="number" phx-value-number="<%= n %>" >
        <span><%= n %></span>
        </div>
        </a>
    <% end %>
    <a href="#">
        <div phx-click="number" phx-value-number=".">
        <span>.</span>
        </div>
    </a>
    <a href="#">
        <div phx-click="number" phx-value-number="0">
        <span>0</span>
        </div>
    </a>
    <a href="#">
        <div phx-click="clear">
        Clear
        </div>
    </a>
    </ul>
    <button type="submit">
        <span class="text-2xl">Save</span>
    </button>
</form>
```

I love working with Liveview and the more I use it the more I am impressed with its simplicity and efficency. 


You can find the project code [here](https://github.com/abarr/fat_fingers)

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>