defmodule Scrabblex.Games.Lexicon do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lexicons" do
    field :name, :string
    field :flag, :string
    field :language, :string
  end

  @doc false
  def changeset(lexicon, attrs) do
    lexicon
    |> cast(attrs, [:name, :language, :flag])
    |> validate_required([:name, :language, :flag])
  end
end
