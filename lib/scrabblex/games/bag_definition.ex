defmodule Scrabblex.Games.BagDefinition do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :score, :integer
    field :value, :string
    field :amount, :integer
  end

  def changeset(bag_definition, attrs \\ %{}) do
    bag_definition
    |> cast(attrs, [:score, :value, :amount])
    |> validate_required([:score, :value, :amount])
  end
end
