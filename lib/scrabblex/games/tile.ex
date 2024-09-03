defmodule Scrabblex.Games.Tile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Scrabblex.Games.Position

  embedded_schema do
    field :score, :integer
    field :value, :string
    field :wildcard, :boolean

    embeds_one :position, Position, on_replace: :delete
  end

  def changeset(tile, attrs) do
    tile
    |> cast(attrs, [:score, :value, :wildcard])
    |> cast_embed(:position)
    |> validate_required([:score, :value, :wildcard])
  end
end
