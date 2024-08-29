defmodule Scrabblex.Games.Tile do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :score, :integer
    field :value, :string
    field :wildcard, :boolean

    embeds_one :position, Position, on_replace: :delete, primary_key: false do
      field :row, :integer
      field :column, :integer
    end
  end

  def changeset(tile, attrs) do
    tile
    |> cast(attrs, [:score, :value, :wildcard])
    |> cast_embed(:position, with: &position_changeset/2)
    |> validate_required([:score, :value, :wildcard])
  end

  defp position_changeset(schema, params) do
    schema
    |> cast(params, [:row, :column])
  end
end
