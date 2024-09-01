defmodule Scrabblex.Games.Play do
  use Ecto.Schema
  import Ecto.Changeset
  alias Scrabblex.Games.{Match, Player, Tile}

  @valid_types ~w(play skip exchange)

  schema "plays" do
    field :score, :integer
    field :turn, :integer
    field :type, :string

    belongs_to :player, Player
    belongs_to :match, Match
    embeds_many :tiles, Tile

    embeds_many :words, Word do
      field :value, :string
      field :score, :integer
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:words, :score, :turn])
    |> cast_embed(:tiles)
    |> cast_embed(:words, with: &word_changeset/2)
    |> validate_required([:score, :turn])
    |> validate_inclusion(:type, @valid_types)
  end

  defp word_changeset(schema, params) do
    schema
    |> cast(params, [:value, :score])
    |> validate_required([:value, :score])
  end
end
