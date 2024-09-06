defmodule Scrabblex.Games.Word do
  use Ecto.Schema

  alias Scrabblex.Games.Position

  import Ecto.Changeset

  embedded_schema do
    field :value, :string
    field :score, :integer
    embeds_many :positions, Position
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:value, :score])
    |> cast_embed(:positions)
    |> validate_required([:value, :score])
  end
end
