defmodule Scrabblex.Games.Tile do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :score, :integer
    field :value, :string
    field :wildcard, :boolean
  end

  def changeset(tile, attrs) do
    tile
    |> cast(attrs, [:score, :value, :wildcard])
    |> validate_required([:score, :value, :wildcard])
  end
end
