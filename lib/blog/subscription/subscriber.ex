defmodule Blog.Subscription.Subscriber do
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:email, :string)
  end

  def changeset(subscriber, attrs \\ %{}) do
    subscriber
    |> cast(attrs, [:email])
    |> validate_required(:email, message: "Please provide an email!")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "Email must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

end
