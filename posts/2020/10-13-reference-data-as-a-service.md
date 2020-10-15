==title==
 Reference Data as a Service
==author==
 Andrew Barr
==description==
 Setting up reference data for small projects or proff of concepts can be a pain. I decided to make a small library to make it simpler. 
==tags==
 weather
==body==

 My First Library
 ----------

I recently started applying for jobs as an Elixir developer. If you are interested in why that is a big step you can check out my about page (hint: I am pretty old).

One piece of feedback I have received in an interview was to start contributing to open source. As many of you know, that can be daunting, so instead, I decided to build a small library to dip my toe in the water.

One thing that I continually find myself doing is creating code and database infrastructure for standard pieces of reference data like gender, months and countries etc. It always felt like a lot of effort for a small benefit (Usually it is collected for the presentation layer rather than complex queries).

My Solution -   <span class="text-blue-600 ">[RefData](https://hex.pm/packages/ref_data) </span>
----------

I created a small library that I can easily add to a `Phoenix` project called `RefData`. My goals are as follows:

<ul class="list-disc ml-10 my-5">
   <li>Reuse defined data across project and POC's</li>
   <li>Make it robust with similar availability to a database</li>
   <li>Very easy to understand</li>
   <li>Learn how to build and publish a library in the Elixir eco-system</li>
</ul>

Data Definition
----------

I wanted an easy way to define data with the least amount of effort so settled on `json`. An example of a data file:

```
{
    "gender": [
        "Male",
        "Female",
        "Non-binary"
    ]
}
```

I also wanted to suport grouped data which will provide headings for sub lists. You define this data folowing standard `json` syntax:

```
{
    "countries_grouped": 
    [
        { "Oceana": ["Australia", "New Zealand"]},
        { "Americas": ["Canada", "USA"]}
    ]
}
```

Data Storage
----------

My next challenge was working out how to store the data. My Blog is built using the methods described in the <span class="text-blue-600">[Dashbit Blog Post](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) </span> about how they built their blog. However, I wanted to try something different so decided to use a `GenServer`. I have no doubt that it is probably overkill but I was able to work with `Supervisors`, `GenServer` and testing processes and cement my learnings.


Building the Library
----------
 <span class="text-blue-600 ">[Source code](https://github.com/abarr/ref_data) </span>

Now that I had decided on the general approach I started by defining an API. I knew that I wanted to focus on supporting `Phoenix.HTML.select` so would be returning a list with `key/value` pairs.

```
[
   [key: "Male", value: "male"],
   [key: "Feale", value: "female"],
   [key: "Non-binary", value: "Non-binary"],
]
```

My API was very simple:

```
defmodule RefData do
  
  defmacro __using__(_opts) do

    quote do

      def list_all_keys() do
        
      end

      def get(key) do
        
      end

      def get(key, :raw) do
        
      end

      def get(key, disabled: list) do
        
      end

      def get(key, _), do: get(key)

    end
  end

```

Next I created my `GenServer` and a seperate helper `module` (You can go to the link above to see the helper functions) for loading and parsing the files.

```
defmodule RefData.Server do
  use GenServer
  alias RefData.Helpers

  def start_link(arg, opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, arg, [name: name])
  end

  def init(arg) do
    table_name = :ets.new(:ref_data, [:named_table, read_concurrency: true])
    Helpers.get_file_paths(arg)
    |> Helpers.load_ref_data()
    {:ok, table_name}
  end

  def handle_call(_ref_data, _from, nil) do
    {:stop, "The Application was unable to load reference data", nil}
  end

  def handle_call({:all_keys}, _from, table_name) do
    {:reply, Enum.into(:ets.tab2list(table_name), [], fn {k, _v} -> k end), table_name}
  end

  def handle_call({key, :raw}, _from, table_name) do
    {:reply, :ets.lookup(table_name, key), table_name}
  end

  def handle_call({key, disabled: disabled_list}, _from, table_name) do
    disabled_list = Helpers.capitalise_list(disabled_list)

    case :ets.lookup(table_name, key) do
      [{_key, value}] ->
        list =
          Enum.into(value, [], fn v -> {v, String.downcase(v)} end)
          |> Enum.into([], fn {k, v} ->
            case Enum.member?(disabled_list, k) do
              true -> [key: k, value: v, disabled: true]
              _ -> [key: k, value: v]
            end
          end)

        {:reply, list, table_name}

      _ ->
        {:error, "Key: #{key} does not exist"}
    end
  end

  def handle_call(key, _from, table_name) do
    value = :ets.lookup(table_name, key)

    case Helpers.is_grouped?(value) do
      true ->
        cond do
          !Helpers.single_level?(value) ->
            {:error, "Incorrect format for #{key}"}

          true ->
            [{_key, list}] = value
            {:reply, Helpers.return_grouped_values(list, []), table_name}
        end

      _ ->
        {:reply, Helpers.return_values(value), table_name}
    end
  end
end
```

Rather than hold the state in the `GenServer` I opted to store the data in `:ets` and pass the `:ets` table name as the state.


Testing
----------

Testing was far more challenging than I expected. Because I am using a `Supervisor` for the `GenServer` I needed to take into a
ccount that the test process becomes the parent for the `GenServer` process. This sent me back to Google to work out what was going on. Luckily 
I found a great post by <span class="text-blue-600 ">[Samuel Mullen called: Elixir Process Testing](https://samuelmullen.com/articles/elixir-processes-testing/) </span>. 
In the end I opted to test the `GenServer` and not the `Application` API. This is something that I intend to refactor in teh coming weeks.


Next Steps
----------

<span class="mb-96">I still have plenty to do on my library (i.e. Refactor for testing, Support GetText and build a demo page) but so far my primary goal of 
extending my Elixir knowledge has been met. Hopefully others will find the library useful or at least be inspired to build their first library.</span>




