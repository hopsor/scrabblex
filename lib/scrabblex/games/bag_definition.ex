defmodule Scrabblex.Games.BagDefinition do
  use Ecto.Schema

  embedded_schema do
    field :score, :integer
    field :value, :string
    field :amount, :integer
  end
end
