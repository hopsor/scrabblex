defmodule Scrabblex.Games.Lexicon do
  use Ecto.Schema

  import Ecto.Changeset

  alias Scrabblex.Games.BagDefinition

  schema "lexicons" do
    field :name, :string
    field :flag, :string
    field :language, :string
    field :enabled, :boolean
    embeds_many :bag_definitions, BagDefinition
  end

  @doc false
  def changeset(lexicon, attrs) do
    lexicon
    |> cast(attrs, [:name, :language, :flag, :enabled])
    |> cast_embed(:bag_definitions)
    |> validate_required([:name, :language, :flag])
  end
end
