defmodule Scrabblex.Games.Lexicon do
  use Ecto.Schema

  import Ecto.Changeset

  alias Scrabblex.Games.BagDefinition

  schema "lexicons" do
    field :name, :string
    field :flag, :string
    field :language, :string
    field :enabled, :boolean
    embeds_many :bag_definitions, BagDefinition, on_replace: :delete
  end

  @doc false
  def changeset(lexicon, attrs) do
    lexicon
    |> cast(attrs, [:name, :language, :flag, :enabled])
    |> validate_required([:name, :language, :flag])
  end

  def bag_definitions_changeset(lexicon, attrs) do
    lexicon
    |> cast(attrs, [])
    |> put_embed(:bag_definitions, attrs["bag_definitions"] || [])
  end
end
