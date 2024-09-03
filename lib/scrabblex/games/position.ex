defmodule Scrabblex.Games.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :row, :integer
    field :column, :integer
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:row, :column])
  end
end
